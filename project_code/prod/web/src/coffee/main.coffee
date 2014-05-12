view     = null
scene    = null
skeleton = null
sync     = null

currMetamorphoseId = 0

setup = ->

  setupPaper()

  setMetamorphose 'tribal'
  # setNextMetamorphose()

  window.addEventListener 'resize', windowResized
  window.addEventListener 'keydown', onKeyDown
  window.addEventListener 'touchstart', onTouchStart
  window.addEventListener 'mousemove', onMouseMove

  windowResized()

setupPaper = ->
  canvas = window.canvas = document.createElement('canvas')
  canvas.id = 'paperjs-canvas'
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
  skeleton.dataRatio = 640 / 480
  view.addChild(skeleton.view)

  # sync = new mk.skeleton.SkeletonSync skeleton
  # sync = new mk.skeleton.SkeletonSync skeleton, 'http://kikko.local:8080'
  sync = new mk.skeleton.SkeletonSync skeleton, 'http://192.158.28.53:80'
  sync.onUserIn = onUserIn
  sync.onUserOut = onUserOut
  sync.onRatio = onRatio
  sync.onDataUpdated = onDataUpdated
  sync.connect()

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
  skeleton.update()
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
  viewport = window.viewport =
    width  : paper.view.viewSize.width
    height : paper.view.viewSize.height
  if skeleton
    skeleton.resize viewport
  scene.resize viewport
  
  view.position.x = (viewport.width) * 0.5
  view.position.y = (viewport.height) * 0.5
  # view.position.x = (viewport.width - view.bounds.width) * 0.5
  # view.position.y = (viewport.height - view.bounds.height) * 0.5

onKeyDown = (ev) ->
  switch ev.keyCode
    when 83 # 's'
      toggleDebug()
    # when 32 # spacebar
      # setNextMetamorphose()

onTouchStart = (ev) ->
  setNextMetamorphose()

onMouseMove = (ev) ->
  window.mouse.x = ev.clientX
  window.mouse.y = ev.clientY

onFrame = (ev) ->
  TWEEN.update()
  skeleton.update()
  scene.setPersoPose skeleton
  scene.update ev.delta

# NiTE events

onUserIn = (userId) ->
  console.log "user #{userId} entered"

onUserOut = (userId) ->
  console.log "user #{userId} exited"

onDataUpdated = () ->
  # perso.setPoseFromSkeleton skeleton


setup()
