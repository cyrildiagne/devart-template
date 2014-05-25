view     = null
scene    = null
skeleton = null
sync     = null
light    = null
playback = null

accumulator = 0
currMetamorphoseId = 0
totalTime = 0

setup = (filename) ->
  setupPaper()

  window.addEventListener 'resize', windowResized
  window.addEventListener 'keydown', onKeyDown
  window.addEventListener 'mousemove', onMouseMove

  setupSkeleton()

  if filename
    setupPlayback filename
  else 
    sync = new mk.skeleton.SkeletonSync skeleton, 7000
    sync.connect()
    setMetamorphose 'birds'

  # dmxLightAnimation()

setupPaper = ->
  canvas = window.canvas = document.getElementById 'paperjs-canvas'
  canvas.setAttribute 'data-paper-hidpi', ''
  canvas.setAttribute 'data-paper-resize', ''
  document.body.appendChild canvas

  paper.setup canvas

  view = new paper.Layer()
  view.pivot = new paper.Point 0,0
  view.transformContent = false
  # view.rotate 90
  # view.scale 0.8
  
setupSkeleton = ->
  skeleton = new mk.skeleton.Skeleton window.debug
  skeleton.setDataRatio 640 / 480
  view.addChild(skeleton.view)

  windowResized()

setupPlayback = (filename) ->
  playback = new mk.playback.Playback skeleton
  playback.load filename, ->
    setMetamorphose 'birds'

# Global Setters

setNextMetamorphose = ->

  if(++currMetamorphoseId >= metamorphoses.length)
    currMetamorphoseId = 0
  m = metamorphoses[currMetamorphoseId]
  setMetamorphose m

setMetamorphose = (m) ->
  setSeed('test')
  window.metamorphose = m
  if scene
    scene.setMetamorphose m
  else
    scene = new mk.Scene onSceneReady
    @setMetamorphose m

toggleDebug = () ->
  window.debug = !window.debug
  skeleton.setDebug window.debug
  skeleton.view.bringToFront()
  scene.setDebug window.debug

onSceneReady = () ->
  view.addChild scene.perso.view
  if paper.view.onFrame is undefined
    paper.view.onFrame = onFrame
  if window.debug
    scene.setDebug true

# System Events

windowResized = (ev) ->
  v =
    width : window.innerWidth
    height : window.innerHeight
  view.scaling = v.height / viewport.height

  view.position.x = v.width * 0.5
  view.position.y = v.height * 0.5

onKeyDown = (ev) ->
  switch ev.keyCode
    when 83 # 's'
      toggleDebug()
    when 32 # spacebar
      setNextMetamorphose()

onMouseMove = (ev) ->
  window.mouse.x = ev.clientX
  window.mouse.y = ev.clientY

onFrame = (ev) ->

  if ev.delta < 0.5
    window.dt = ev.delta
  else console.log "resumed"

  if playback
    playback.update window.dt

  dt = 1 / 50
  accumulator += window.dt
  i = 0
  while accumulator >= dt
    totalTime += dt * 1000
    TWEEN.update totalTime
    skeleton.update dt*7
    scene.setPersoPose skeleton
    scene.update dt
    accumulator -= dt

# MISCELLANEOUS

dmxLightAnimation = ->
  light = new ArtNetClient '192.168.0.2', 6454, ->
    i = 0
    speed = 0.05
    setInterval ->
      i += Math.PI / 2 * speed
      val = Math.floor( (1 + Math.sin(i)) * 127 )
      light.send([val])
    , 1000/30

setup 'saved/skel.bin'
# setup()

