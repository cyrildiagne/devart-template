isLive      = false
chromeAppId = 'chrome-extension://cjmhlclabilhdpnenenfbpgpmnbejpnf'

iframe      = null
quadwarp    = null
gcs         = null
scenes      = null
currSceneId = -1
isReady     = false

currSceneName = null

currentMode    = 0
SCENE_INIT     = 'scene_init'
SCENE_LOADING  = 'scene_loading'
SCENE_RUNNING  = 'scene_running'
SCENE_CHANGING = 'scene_changing'
SCENE_ENDING   = 'scene_ending'

$currSceneBt = null
$title = null
$timeline = null
$status = null
$sound = null
$help = null
$iframe = null

uiHideTimeout = -1

if typeof chrome isnt 'undefined' && chrome.sockets
  isLive = true

initApp = ->
  $iframe = $("#frame")
  if isLive
    gcs = new CloudStorage()
    quadwarp = new QuadWarp $iframe[0], 'kalia_quadwarp'
    scenes = ['tiroirs', 'tribal', 'stripes', 'birds', 'lockers', 'tiroirs', 'books', 'bulbs']
    currSceneId = 0
    launchCurrentScene()
  else
    $title = $('#title').html('Les Métamorphoses de Mr. Kalia')
    $status = $('#date')
    sceneName = getHashParam 'scene'
    getList sceneName, (data) ->
      scenes = data
      if sceneName
        currSceneId = getSceneIndexByName sceneName
      else
        currSceneId = scenes.length-1
      playbackInfoLoaded()

playbackInfoLoaded = ->
  setupUI()
  setupHashNav()
  updateTimelineView()
  launchCurrentScene()

getSceneIndexByName = (sceneName) ->
  idx = 0
  for i in [0...scenes.length]
    return i if scenes[i].tag is sceneName
  return 0

getHashParam = (key)->
   query = window.location.hash.substring 1
   vars = query.split '&'
   for i in [0...vars.length]
    pair = vars[i].split("=")
    if pair[0] is key
      return pair[1] || true
   return false

getList = (scene, callback) ->
  url = Config::indexURL + '&scene=' + scene
  console.log 'APP > retrieving index ' + url
  $status.html 'RETRIEVING PERFORMANCES LIST'
  r = new XMLHttpRequest()
  r.onload = () =>
    if r.status is 200
      items = JSON.parse(r.responseText)
      data = []
      for i in [0...items.length]
        infos = items[i].split '_'
        if infos.length is 3
          data.push
            tag   : items[i]
            date  : new Date(parseInt(infos[0]))
            seed  : infos[1]
            scene : infos[2]
      callback data
    else console.log 'error'
  r.open 'GET', url
  setTimeout ->
    r.send()
  , 100

next = ->
  nextSceneId = currSceneId+1
  if currentMode is SCENE_RUNNING
    if nextSceneId >= scenes.length then nextSceneId = 0
    sceneName = scenes[nextSceneId].tag
    window.location.hash = 'scene='+sceneName

prev = ->
  prevSceneId = currSceneId-1
  if currentMode is SCENE_RUNNING
    if prevSceneId < 0 then prevSceneId = scenes.length-1
    sceneName = scenes[prevSceneId].tag
    window.location.hash = 'scene='+sceneName

changeScene = ->
  updateTimelineView()
  $status.html ''
  sendCommand 'finish','*'

launchCurrentScene = ->
  currScene = scenes[currSceneId]
  sendCommand 'launch ' + (currScene.tag || currScene), '*'

setSceneFromName = (sceneName) ->
  idx = getSceneIndexByName sceneName
  console.log 'set scene from name ' + sceneName
  if idx >= 0 and idx != currSceneId 
    currSceneId = idx
    if currentMode is SCENE_RUNNING
      changeScene()


# ---- UI -----

setupHashNav = ->
  $(window).on 'hashchange', hashChanged

hashChanged = ->
  if currentMode is SCENE_RUNNING
    scene = getHashParam 'scene'
    if scene then setSceneFromName scene
  goto = getHashParam 'goto'
  if goto then sendCommand 'goto '+goto,'*'
  pause = getHashParam 'pause'
  if pause then sendCommand 'pause'
  mute = getHashParam 'mute'
  if mute then sendCommand 'mute'

setupUI = ->
  setupMuteButton()
  setupHelpButton()
  setupTimeline()
  setupArrows()
  setupAutoHide()
  $(window).on 'resize', ->
    mouseMoveTimeline {x:window.innerWidth*0.5}
  $(window).on 'focus', ->
    sendCommand 'focus'
  $(window).on 'blur', ->
    sendCommand 'focusout'

setupAutoHide = ->
  $('html').mousemove ->
    if !$('#about').hasClass('inactive') then return
    if currentMode is SCENE_RUNNING
      $('#ui').removeClass 'inactive'
      clearTimeout uiHideTimeout
      uiHideTimeout = setTimeout ->
        $('#ui').addClass 'inactive'
      , 2000

setupMuteButton = ->
  $sound = $('#sound')
  $sound.on 'click', (ev) ->
    ev.originalEvent.preventDefault()
    sendCommand('toggle_mute')

setupHelpButton = ->
  $help = $('#help')
  $('#about').on 'click', closeAbout

  $help.on 'click', (ev) ->
    ev.originalEvent.preventDefault()
    $('#about').removeClass 'inactive'
    $('#ui').addClass 'inactive'
    $title.hide()
    $status.hide()
    # $iframe.focusout()
    # setTimeout(->
    # $('html').on 'click', closeAbout
    # ,1)

closeAbout = (ev) ->
  if $(ev.target).attr('href')
    return
  ev.originalEvent.preventDefault()
  $('#about').addClass 'inactive'
  $('#ui').removeClass 'inactive'
  $title.show()
  $status.show()
  # $iframe.focus()
  $('html').off 'click', closeAbout

setupTimeline = ->
  $timeline = $('#timeline')
  for i in [0...scenes.length]
    s = scenes[i]
    time = s.date.getHours() + ':' + s.date.getMinutes()
    $tmlItem = $('<a>').addClass(s.scene)
    $tmlItem.attr 'data-content', time + ' | ' + s.scene.toUpperCase()
    $tmlItem.attr 'href', '/#scene='+s.tag
    $timeline.append $tmlItem
  
  setTimeout ->
    mouseMoveTimeline {x:window.innerWidth*0.5}
    if window.innerWidth < $timeline.width()
      $timeline.on 'mousemove', mouseMoveTimeline
  , 100

setupArrows = ->
  $('.arrow.left').on 'click', prev
  $('.arrow.right').on 'click', next

setSceneDate = ->
  d = scenes[currSceneId].date
  min = d.getMinutes()
  if min < 10 then min = '0'+min
  time = d.getHours() + ':' + min
  day = d.getDate()
  if day < 10 then day = '0'+day
  m = d.getMonth()+1
  if m < 10 then m = '0'+m
  date = day + '/' + m + '/' + d.getFullYear()
  $status.html time + ' | ' + date

# mouseDownTimeline = (e) ->
  # if currentMode is SCENE_RUNNING
  #   set $(e.target).index()

updateTimelineView = ->
  if isLive then return
  bt = $timeline.children().eq(currSceneId)
  # color = bt.css('background-color')
  # console.log color
  if $currSceneBt then $currSceneBt.removeClass 'on'
  $currSceneBt = $(bt).addClass 'on'

updateLoading = (msg) ->
  if isLive then return
  $status.html 'LOADING ' + (msg || 'Scene')

mouseMoveTimeline = (e) ->
  pct = (e.x-20) / (window.innerWidth-40)
  pos = - pct*($timeline.width()-window.innerWidth)
  $timeline[0].style.WebkitTransform = 'translate('+pos+'px, 0)'


# ---- RECORDED FILE UPLOAD

saveCurrentToGCS = (data) ->
  console.log 'APP > uploading ' + currSceneName + ' - length: ' + data.length
  blob = new Blob [data], {type: 'application/octet-binary'}
  gcs.upload currSceneName, blob, ->
    console.log 'APP > file uploaded'


# ---- IFRAME COMMUNICATION ----

sendCommand = (cmd) ->
  $iframe[0].contentWindow.postMessage cmd,'*'

window.onmessage = (e) ->
  # if e.origin != chromeAppId then return
  if e.data instanceof Float32Array
    saveCurrentToGCS e.data
    return
  args = e.data.split ':'
  switch args[0]
    when 'init'
      console.log 'APP > scene inited'
      if scenes is null
        initApp()
      else if currentMode is SCENE_CHANGING
        launchCurrentScene()
      currentMode = SCENE_INIT
    when 'loading'
      if args.length is 1
        console.log 'APP > scene loading'
        currentMode = SCENE_LOADING
        updateLoading()
      else
        updateLoading(args[1])
    when 'loaded'
      console.log 'APP > scene loaded'
      if !isLive
        $status.html 'setting up performance'
      if $.browser.mobile
        sendCommand 'mobile', '*'
    when 'started'
      console.log 'APP > scene started'
      currentMode = SCENE_RUNNING
      hashChanged()
      if !isLive
        $('#ui').removeClass 'inactive'
        setSceneDate()
    when 'finishing'
      console.log 'APP > scene finishing'
      currentMode = SCENE_CHANGING
      if !isLive
        $('#ui').addClass 'inactive'
        $status.html 'closing performance'
    when 'finished'
      console.log 'APP > scene finished'
      if isLive
        currSceneId = Math.floor(Math.random()*scenes.length)
      else
        $status.html 'cleaning up the stage'
      $iframe[0].contentWindow.location.reload()
    when 'mute'
      $sound.addClass 'off'
    when 'unmute'
      $sound.removeClass 'off'
    when 'upload'
      currSceneName = args[1]
    else
      console.log 'app received unknown message : ' + e.data
