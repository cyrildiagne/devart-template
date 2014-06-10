iframe      = null
quadwarp    = null
timeline    = null
scenes      = null
currSceneId = -1
isLive      = false
isReady     = false
isSceneLoading = false
isSceneLaunched = false
isSceneFinishing = false
currSceneBt = null
statusDom = null

bucketName = 'mr-kalia-replays'
maxReplays = '150'

window.onmessage = (e) ->
  if e.data == "ready"
    isReady = true
    isSceneFinishing = false
    console.log "ready"
    if scenes and !isSceneLaunched then launchCurrentScene()
  else if e.data == "scene_loaded"
    console.log 'APP > scene loaded'
    setSceneDate()
    isSceneLoading = false
  else if e.data == "next_scene"
    console.log 'APP > wants next scene'
    if isLive
      currSceneId = Math.floor(Math.random()*scenes.length)
    else
      # next()
      # if currSceneId++ > scenes.length then currSceneId = 0
    isSceneLaunched = false
    iframe.contentWindow.location.reload()
  # else
    # console.log 'app received unknown message : ' + e.data

getIndex = (callback) ->
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
  r.open 'GET', 'https://www.googleapis.com/storage/v1/b/'+bucketName+'/o?maxResults='+maxReplays+'&fields=nextPageToken,items(name,size)'
  r.send()

next = ->
  currSceneId++
  if currSceneId >= scenes.length then currSceneId = 0

prev = ->
  currSceneId--
  if currSceneId < 0 then currSceneId = scenes.length-1

launchCurrentScene = ->
  currScene = scenes[currSceneId]
  iframe.contentWindow.postMessage (currScene.tag || currScene), '*'
  isSceneLoading = true
  isSceneLaunched = true
  statusDom.innerHTML = "LOADING..."

setSceneDate = ->
  d = scenes[currSceneId].date
  time = d.getHours() + ':' + d.getMinutes()
  date = d.getDate() + '/' + d.getMonth() + '/' + d.getFullYear()
  statusDom.innerHTML = time + ' | ' + date

setupTimeline = ->
  timeline = document.createElement 'div'
  timeline.id = 'timeline'
  for i in [0...scenes.length]
    scene = scenes[i]
    s = document.createElement 'div'
    s.className = scene.scene
    timeline.appendChild s
  
  setTimeout ->
    timeline.addEventListener 'mousedown', mouseDownTimeline
    mouseMoveTimeline {x:window.innerWidth*0.5}
    if window.innerWidth < timeline.innerWidth
      timeline.addEventListener 'mousemove', mouseMoveTimeline
  , 1000
  document.body.appendChild timeline

setupArrows = ->
  for i in [0...2]
    arrow = document.createElement 'div'
    arrow.className = 'arrow'
    document.body.appendChild arrow
    arrow.addEventListener 'click', arrowClicked
  arrow.className = arrow.className + ' right'

arrowClicked = (e) ->
  e.preventDefault()
  if e.target.className is 'arrow' then prev() else next()
  sceneChange()

mouseDownTimeline = (e) ->
  idx = Array.prototype.indexOf.call(timeline.children, e.target)
  currSceneId = idx
  sceneChange()

sceneChange = ->
  bt = timeline.children[currSceneId]
  cs = document.defaultView.getComputedStyle bt,null
  color = cs.getPropertyValue 'background-color'
  
  bt.className = bt.className + ' on'
  if currSceneBt
    cname = currSceneBt.className.replace(/\bon\b/,'')
    currSceneBt.className = cname
  currSceneBt = bt
  if isSceneLaunched and !isSceneFinishing
    statusDom.innerHTML = ""
    iframe.contentWindow.postMessage 'stop','*'
    isSceneFinishing = true

mouseMoveTimeline = (e) ->
  pct = (e.x-20) / (window.innerWidth-40)
  pos = - pct*(timeline.offsetWidth-window.innerWidth)
  timeline.style.WebkitTransform = 'translate('+pos+'px, 0)'

iframe = document.getElementById "frame"
statusDom = document.getElementById 'date'

if isLive
  quadwarp = new QuadWarp iframe
  scenes = ['tiroirs']
  currSceneId = 0
else
  getIndex (data) ->
    scenes = data
    setupTimeline()
    setupArrows()
    currSceneId = 0#Math.floor scenes.length * 0.5
    sceneChange()
    if isReady and !isSceneLaunched then launchCurrentScene()

# data = new Uint8Array(5120)
# for i in [0...data.length]
#   data[i] = i % 255
# gcs = new CloudStorage()
# gcs.upload 'test.bin', data
