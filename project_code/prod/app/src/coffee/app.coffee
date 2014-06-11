iframe      = null
quadwarp    = null
scenes      = null
currSceneId = -1
isLive      = false
isReady     = false

currentMode = 0
SCENE_INIT      = 'scene_init'
SCENE_LOADING   = 'scene_loading'
SCENE_RUNNING   = 'scene_running'
SCENE_CHANGING  = 'scene_changing'
SCENE_ENDING    = 'scene_ending'

$currSceneBt = null
$timeline = null
$status = null
$sound = null
uiHideTimeout = -1

initApp = ->
  iframe = $("#frame")[0]
  if isLive
    quadwarp = new QuadWarp iframe
    scenes = ['tiroirs']
    currSceneId = 0
  else
    getIndex (data) ->
      scenes = data
      setupUI()
      setupHashNav()
      currSceneId = scenes.length-1
      updateTimelineView()
      launchCurrentScene()

getHashParam = (key)->
   query = window.location.hash.substring 1
   vars = query.split '&'
   for i in [0...vars.length]
    pair = vars[i].split("=")
    if pair[0] is key
      return pair[1] || true
   return false

getIndex = (callback) ->
  console.log 'APP > retrieving index ' + Config::indexURL
  r = new XMLHttpRequest()
  r.onload = () =>
    if r.status is 200
      items = JSON.parse(r.responseText).items
      data = []
      for i in [0...items.length]
        infos = items[i].name.split '_'
        if infos.length is 3
          data.push
            tag   : items[i].name
            size  : items[i].size
            date  : new Date(parseInt(infos[0]))
            seed  : infos[1]
            scene : infos[2]
      callback data
    else console.log 'error'
  r.open 'GET', Config::indexURL
  setTimeout ->
    r.send()
  , 100

next = ->
  if currentMode is SCENE_RUNNING
    if ++currSceneId >= scenes.length then currSceneId = 0
    changeScene()

prev = ->
  if currentMode is SCENE_RUNNING
    if --currSceneId < 0 then currSceneId = scenes.length-1
    changeScene()

set = (idx) ->
  if currentMode is SCENE_RUNNING
    currSceneId = idx
    changeScene()

changeScene = ->
  updateTimelineView()
  $status.html ''
  sendCommand 'finish','*'

launchCurrentScene = ->
  currScene = scenes[currSceneId]
  sendCommand 'launch ' + (currScene.tag || currScene), '*'


# ---- UI -----

setupHashNav = ->
  $(window).on 'hashchange', hashChanged

hashChanged = ->
  goto = getHashParam 'goto'
  if goto then sendCommand 'goto '+goto,'*'
  pause = getHashParam 'pause'
  if pause then sendCommand 'pause'
  mute = getHashParam 'mute'
  if mute then sendCommand 'mute'

setupUI = ->
  $status = $('#date')
  setupMuteButton()
  setupTimeline()
  setupArrows()
  $(window).on 'resize', ->
    mouseMoveTimeline {x:window.innerWidth*0.5}
  # $(window).mousemove ->
  #   if currentMode is SCENE_RUNNING
  #     $('#ui').removeClass 'inactive'
  #     clearTimeout uiHideTimeout
  #     uiHideTimeout = setTimeout ->
  #       $('#ui').addClass 'inactive'
  #     , 2000

setupMuteButton = ->
  $sound = $('#sound')
  $sound.on 'click', (ev) ->
    ev.originalEvent.preventDefault()
    sendCommand('toggle_mute')

setupTimeline = ->
  $timeline = $('#timeline')
  for i in [0...scenes.length]
    $timeline.append $('<div>').addClass(scenes[i].scene)
  
  setTimeout ->
    $timeline.on 'mousedown', mouseDownTimeline
    mouseMoveTimeline {x:window.innerWidth*0.5}
    if window.innerWidth < $timeline.width()
      $timeline.on 'mousemove', mousemovetimeline
  , 100

setupArrows = ->
  $('.arrow.left').on 'click', prev
  $('.arrow.right').on 'click', next

setSceneDate = ->
  d = scenes[currSceneId].date
  time = d.getHours() + ':' + d.getMinutes()
  day = d.getDate()
  if day < 10 then day = '0'+day
  m = d.getMonth()
  if m < 10 then m = '0'+m
  date = day + '/' + m + '/' + d.getFullYear()
  $status.html 'PERF. N°'+currSceneId + ' - ' + time + ' | ' + date

mouseDownTimeline = (e) ->
  if currentMode is SCENE_RUNNING
    set $(e.target).index()

updateTimelineView = ->
  bt = $timeline.children().eq(currSceneId)
  # color = bt.css('background-color')
  # console.log color
  if $currSceneBt then $currSceneBt.removeClass 'on'
  $currSceneBt = $(bt).addClass 'on'

updateLoading = (msg) ->
  $status.html 'LOADING ' + (msg || 'Scene')

mouseMoveTimeline = (e) ->
  pct = (e.x-20) / (window.innerWidth-40)
  pos = - pct*($timeline.width()-window.innerWidth)
  $timeline[0].style.WebkitTransform = 'translate('+pos+'px, 0)'



# ---- IFRAME COMMUNICATION ----


sendCommand = (cmd) ->
  iframe.contentWindow.postMessage cmd,'*'

window.onmessage = (e) ->
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
      $status.html 'setting up performance'
    when 'started'
      console.log 'APP > scene started'
      $('#ui').removeClass 'inactive'
      currentMode = SCENE_RUNNING
      setSceneDate()
      hashChanged()
    when 'finishing'
      console.log 'APP > scene finishing'
      $('#ui').addClass 'inactive'
      $status.html 'closing performance'
      currentMode = SCENE_CHANGING
    when 'finished'
      console.log 'APP > scene finished'
      $status.html 'cleaning up the stage'
      if isLive
        currSceneId = Math.floor(Math.random()*scenes.length)
      iframe.contentWindow.location.reload()
    when 'mute'
      $sound.addClass 'off'
    when 'unmute'
      $sound.removeClass 'off'
    else
      console.log 'app received unknown message : ' + e.data