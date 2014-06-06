view     = null
scene    = null
skeleton = null
sync     = null
light    = null
playback = null
record   = null
canvas = null

isLoading = false
isLive = false
accumulator = 0
currMetamorphoseId = 0
currentTime = 0
timestamp = 0
frameNum = 0

setupPlayback = (filename) ->
  console.log 'Setting up playback ' + filename
  isLive = false
  isLoading = true
  setupApp()
  playback = new mk.playback.Playback skeleton, onPlaybackComplete
  playback.load filename, (seed, m11) ->
    # setSeed seed
    setSeed new Date().getTime()
    setMetamorphose m11

setupLive = (m11) ->
  console.log 'Setting up live ' + m11
  isLive = true
  isLoading = true
  light = new mk.physical.DMXLight()
  light.setup()
  setupApp()
  seed = new Date().getTime()
  setSeed seed
  setMetamorphose m11
  record = new mk.playback.Record()


# Setup 

setupApp = ->
  setupPaper()

  window.addEventListener 'resize', windowResized
  window.addEventListener 'focus', windowFocus
  window.addEventListener 'blur', windowLostFocus
  window.addEventListener 'keydown', onKeyDown
  window.addEventListener 'mousemove', onMouseMove

  setupSkeleton()

setupPaper = ->
  canvas = window.canvas = document.getElementById 'paperjs-canvas'
  canvas.setAttribute 'data-paper-hidpi', ''
  canvas.setAttribute 'data-paper-resize', ''
  canvas.style.display = 'block'
  document.body.appendChild canvas

  paper.setup canvas

  view = new paper.Layer()
  view.pivot = new paper.Point 0,0
  view.transformContent = false
  
setupSkeleton = ->
  skeleton = new mk.skeleton.Skeleton window.debug
  skeleton.setDataRatio 800 / 480
  view.addChild(skeleton.view)

  windowResized()


# Global Setters

setNextMetamorphose = ->
  if(++currMetamorphoseId >= metamorphoses.length)
    currMetamorphoseId = 0
  m = metamorphoses[currMetamorphoseId]
  setMetamorphose m

setMetamorphose = (m) ->
  window.metamorphose = m
  if scene
    scene.setMetamorphose m
  else
    scene = new mk.Scene onSceneReady, onSceneFinished
    @setMetamorphose m

toggleDebug = () ->
  window.debug = !window.debug
  skeleton.setDebug window.debug
  skeleton.view.bringToFront()
  scene.setDebug window.debug

onSceneReady = () ->
  console.log '> scene ready'
  view.addChild scene.perso.view

  if window.debug
    scene.setDebug true

  if isLive
    sync = new mk.skeleton.SkeletonSync skeleton, 7000
    sync.onFirstUserIn = onFirstUserIn
    sync.onLastUserOut = onLastUserOut
    sync.connect false #true
    record.begin 
      timestamp : window.seed
      m11  : window.metamorphose

  isLoading = false

  if playback || sync.bMinOneUser
    beginScene()

  window.top.postMessage 'scene_loaded', '*'

beginScene = ->
  if scene.isStarted then return
  console.log '> begin scene'
  if isLive
    light.fadeTo 0.2, 2000
  curtainUp isLive, ->
    start()

    # if playback
    #   goto 1500, false
    # fadeScene 'on', 1000

finishScene = ->
  # if !scene.isStarted then return
  if isLoading then return
  console.log '> finish scene'
  onSceneFinished()

onSceneFinished = () ->
  console.log '> scene finished'
  curtainDown isLive, ->
    if isLive
      light.fadeTo 1, 3000
  # fadeScene 'off', 1000
  scene.fadeOut()
  setTimeout ->
    stop()
    clean ->
      # record.end()
      window.top.postMessage 'next_scene', '*'
  , 4000

start = () ->
  if isLoading then return
  if !paper.view.onFrame
    paper.view.onFrame = onFrame
  scene.start()
  console.log '> started'

stop = () ->
  if isLoading then return
  paper.view.onFrame = undefined  
  scene.stop()
  console.log '> stopped'

clean = (callback) ->
  if isLive
    sync.close ->
      callback()
  else callback()

goto = (frame, bStop = false, dt = 1/50) ->
  if frame < frameNum
    console.log "Can't go backward yet.."
    return
  scene.music.stop()
  scene.mute()
  update dt for i in [frameNum...frame]
  scene.music.play()
  scene.unmute()
  if bStop
    stop()

onPlaybackComplete = () ->
  # ...

onFirstUserIn = () ->
  console.log 'first user in'
  beginScene()

onLastUserOut = () ->
  console.log 'last user out'
  finishScene()

# System Events

windowResized = (ev) ->
  v =
    width : window.innerWidth
    height : window.innerHeight
  view.scaling = v.height / viewport.height#* 0.85

  view.position.x = v.width * 0.5
  view.position.y = v.height * 0.5

windowFocus = (ev) ->
  start()

windowLostFocus = (ev) ->
  stop()

onKeyDown = (ev) ->
  switch ev.keyCode
    when 83 # 's'
      toggleDebug()
      # if record
      #   record.end()
    when 32 # spacebar
      setNextMetamorphose()

onMouseMove = (ev) ->
  window.mouse.x = ev.clientX
  window.mouse.y = ev.clientY

onFrame = (ev) ->
  if ev.delta < 0.5
    window.dt = ev.delta
  update window.dt

update = (deltaTime) ->

  deltaTime *= 1000

  if isLive
    record.update deltaTime
    if sync.hasNewData
      skeleton.setData sync.data
      record.addFrame sync.data
      sync.hasNewData = false

  dt = 1000 / 50
  accumulator += deltaTime
  while accumulator >= dt

    if playback
      playback.update dt
    
    currentTime += dt
    frameNum++
    window.currentTime = currentTime

    TWEEN.update currentTime
    skeleton.update dt*0.008
    scene.setPersoPose skeleton
    scene.update dt, currentTime
    accumulator -= dt

# MISCELLANEOUS

window.onmessage = (e) ->
  arg = e.data
  if arg.split("_").length > 1
    setupPlayback arg
  else if arg == 'stop'
    console.log 'stop'
    finishScene()
  else if arg != 'ready'
    setupLive arg

window.top.postMessage 'ready', '*'