view     = null
scene    = null
skeleton = null
sync     = null
light    = null

accumulator = 0
currMetamorphoseId = 0

setup = ->
  setupPaper()
  startLightAnimation()

  setMetamorphose 'bulbs'
  # setNextMetamorphose()

  window.addEventListener 'resize', windowResized
  window.addEventListener 'keydown', onKeyDown
  window.addEventListener 'touchstart', onTouchStart
  window.addEventListener 'mousemove', onMouseMove

  windowResized()

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

  sync = new mk.skeleton.SkeletonSync skeleton, 7000
  sync.onUserIn = onUserIn
  sync.onUserOut = onUserOut
  sync.onRatio = onRatio
  sync.onDataUpdated = onDataUpdated
  sync.connect()

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
    scene = new mk.Scene onSceneReady
    @setMetamorphose m

toggleDebug = () ->
  window.debug = !window.debug
  skeleton.setDebug window.debug
  # skeleton.update()
  skeleton.view.bringToFront()
  scene.setDebug window.debug

onSceneReady = () ->
  view.addChild scene.perso.view
  if paper.view.onFrame is undefined
    setupSkeleton()
    paper.view.onFrame = onFrame
  if window.debug
    scene.setDebug true

# System Events

onRatio = (ratio) ->
  skeleton.dataRatio = ratio
  windowResized()
  console.log 'ratio set to '+ ratio

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

onTouchStart = (ev) ->
  setNextMetamorphose()

onMouseMove = (ev) ->
  window.mouse.x = ev.clientX
  window.mouse.y = ev.clientY

onFrame = (ev) ->
  TWEEN.update()
  
  if ev.delta < 0.1
    window.dt = ev.delta
  else console.log "resumed"
  
  dt = 1 / 50
  accumulator += window.dt
  i = 0
  while accumulator >= dt
    skeleton.update dt
    scene.setPersoPose skeleton
    scene.update dt
    accumulator -= dt

# NiTE events

onUserIn = (userId) ->
  console.log "user #{userId} entered"

onUserOut = (userId) ->
  console.log "user #{userId} exited"

onDataUpdated = () ->
  # perso.setPoseFromSkeleton skeleton
  # console.log skeleton.toString()
  # console.log skeleton.width

# MISCELLANEOUS

startLightAnimation = ->
  light = new ArtNetClient '192.168.0.2', 6454, ->
    i = 0
    speed = 0.05
    setInterval ->
      i += Math.PI / 2 * speed
      val = Math.floor( (1 + Math.sin(i)) * 127 )
      light.send([val])
    , 1000/30

setup()

