params =
  colors : [0x35a1af, 0x7da2a1, 0x4e976b, 0x79a262, 0xd1e6ba, 0x3b6b78, 0xe73464, 0xc6d8d6]
  numParticles : 175
  numPlops : 3
  radius : 150 * window.devicePixelRatio
  animatedRatio : 0.1

handheld = window.innerWidth < 640
if handheld
  params.numPlops = 3

img_suffix = ''
if window.devicePixelRatio > 1.0
  img_suffix = '-hd'

stats = null
stage = null
renderer = null
plops = []
mouse = {x:0, y:0}
touch = {x:0, y:0}
touchInit = {x:0, y:0}
cameraPosition = {x:0, y:0}
cameraPositionInit = {x:0, y:0}
appWidth = window.innerWidth
appHeight = window.innerHeight

setup = ->
  stats = new Stats()
  document.body.appendChild stats.domElement
  stage = new PIXI.Stage(0xFFFFFF)
  renderer = PIXI.autoDetectRenderer(appWidth, appHeight)
  windowResized()
  load()
  document.body.appendChild(renderer.view)
  window.addEventListener('resize', windowResized)
  if handheld
    renderer.view.addEventListener('touchstart', touchStarted)
    renderer.view.addEventListener('touchmove', touchMoved)
  else
    renderer.view.addEventListener('mousemove', mouseMoved)

windowResized = (ev) ->
  appWidth = window.innerWidth
  appHeight = window.innerHeight
  renderer.resize(appWidth*window.devicePixelRatio, appHeight*window.devicePixelRatio)
  renderer.view.style.width = appWidth + 'px'
  renderer.view.style.height = appHeight + 'px'

mouseMoved = (ev) ->
  mouse.x = ev.pageX * window.devicePixelRatio
  mouse.y = ev.pageY * window.devicePixelRatio

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

load = ->
  assetsToLoader = [ 'assets/plop_anim' + img_suffix + '.json']
  loader = new PIXI.AssetLoader(assetsToLoader)
  loader.onComplete = onAssetsLoaded
  loader.load()

onAssetsLoaded = ->
  for i in [0...params.numPlops]
    plop = new Plop()
    plop.position.x = (i - (params.numPlops-1)*0.5) * (params.radius * 2 + 50)
    stage.addChild plop
    plops.push plop
  requestAnimFrame animate

animate = ->
  stats.begin()
  requestAnimFrame animate
  if handheld
    for p in plops
      p.update cameraPosition.x, cameraPosition.y
  else
    for p in plops
      p.update mouse.x, mouse.y
  
  renderer.render stage
  stats.end()

setup()
