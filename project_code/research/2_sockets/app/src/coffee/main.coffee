params =
  colors : [0x35a1af, 0x7da2a1, 0x4e976b, 0x79a262, 0xd1e6ba, 0x3b6b78, 0xe73464, 0xc6d8d6]
  numParticles : 175
  numPlops : 1
  radius : 150 * window.devicePixelRatio
  animatedRatio : 0.2

handheld = window.innerWidth <= 640

stage = null
renderer = null
assets = null
plops = []

viewports = null

socket = null
socket_id = null

mouse = {x:0, y:0}
touch = {x:0, y:0}
touchInit = {x:0, y:0}
cameraPosition = {x:0, y:0}
cameraPositionInit = {x:0, y:0}

appWidth = window.innerWidth
appHeight = window.innerHeight

setup = ->
  stage = new PIXI.Stage(0xFFFFFF)
  renderer = PIXI.autoDetectRenderer(appWidth, appHeight)

  document.body.appendChild(renderer.view)
  if handheld
    renderer.view.style.display = 'none'

  windowResized()
  window.addEventListener('resize', windowResized)
  if handheld
    renderer.view.addEventListener('touchstart', touchStarted)
    renderer.view.addEventListener('touchmove', touchMoved)
  else
    renderer.view.addEventListener('mousemove', mouseMoved)

  assets = new Assets()
  assets.load onAssetsLoaded

onAssetsLoaded = ->
  for i in [0...params.numPlops]
    plop = new Plops()
    plop.view.position.x = (i - (params.numPlops-1)*0.5) * (params.radius * 2 + 50)
    stage.addChild plop.view
    plops.push plop
  if !handheld
    viewports = new Viewports()
    stage.addChildAt viewports.view, 0
  connect()
  requestAnimFrame animate

connect = ->
  socket = io.connect 'http://kikko.local:8080'
  socket.on 'connect', onSocketConnected
  socket.on 'id', (id) ->
    socket_id = id
    if handheld
      socket.emit 'viewport_enter', socket_id, cameraPosition.x, cameraPosition.y, appWidth, appHeight

onSocketConnected = ->
  if handheld
    socket.on 'blob_position', (position) ->
      position.x *= window.devicePixelRatio
      position.y *= window.devicePixelRatio
      if mouse.x is 0 && mouse.y is 0
        for p in plops
          p.setPosition position
        setTimeout( ->
          renderer.view.style.display = 'block'
        , 1)
      mouse = position
  else
    socket.on 'viewport_enter', (id, x, y, width, height) ->
      viewports.add id, x, y, width, height
    socket.on 'viewport_resize', (id, width, height) ->
      viewports.resize id, width, height
    socket.on 'viewport_move', (id, x, y) ->
      viewports.move id, x, y
    socket.on 'viewport_exit', (id) ->
      viewports.remove id

windowResized = (ev) ->
  appWidth = window.innerWidth
  appHeight = window.innerHeight
  renderer.resize(appWidth*window.devicePixelRatio, appHeight*window.devicePixelRatio)
  renderer.view.style.width = appWidth + 'px'
  renderer.view.style.height = appHeight + 'px'
  if handheld and socket
    socket.emit 'viewport_resize', socket_id, appWidth, appHeight

mouseMoved = (ev) ->
  mouse.x = ev.pageX * window.devicePixelRatio
  mouse.y = ev.pageY * window.devicePixelRatio
  if socket
    socket.emit 'position',
      x : mouse.x
      y : mouse.y

touchStarted = (ev) ->
  touchInit = 
    x : ev.touches[0].pageX * window.devicePixelRatio
    y : ev.touches[0].pageY * window.devicePixelRatio
  cameraPositionInit.x = cameraPosition.x
  cameraPositionInit.y = cameraPosition.y

touchMoved = (ev) ->
  touch.x = ev.touches[0].pageX * window.devicePixelRatio
  touch.y = ev.touches[0].pageY * window.devicePixelRatio
  cameraPosition.x = cameraPositionInit.x + (touch.x - touchInit.x)
  cameraPosition.y = cameraPositionInit.y + (touch.y - touchInit.y)
  cameraPosition.x = Math.min(0, cameraPosition.x)
  cameraPosition.y = Math.min(0, cameraPosition.y)
  if handheld and socket
    x = -cameraPosition.x / window.devicePixelRatio
    y = -cameraPosition.y / window.devicePixelRatio
    socket.emit 'viewport_move', socket_id, x, y

animate = ->
  requestAnimFrame animate
  for p in plops
    p.view.x = cameraPosition.x
    p.view.y = cameraPosition.y
    p.update mouse
  if !handheld
    viewports.update()
  renderer.render stage

setup()
