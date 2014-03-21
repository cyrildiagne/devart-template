stage = null
renderer = null
skeleton = null
sync = null
perso = null
debug = false

setup = ->
  stage = new PIXI.Stage(0xFFFFFF)
  renderer = PIXI.autoDetectRenderer window.innerWidth, window.innerHeight, null, false, true
  document.body.appendChild(renderer.view)

  skeleton = new Skeleton()
  stage.addChild skeleton.view

  perso = new Perso false
  stage.addChild perso.view

  sync = new SkeletonSync skeleton, 'http://kikko.local:8080'
  # sync = new SkeletonSync skeleton, 'http://192.158.28.53:80'
  sync.onUserIn = onUserIn
  sync.onUserOut = onUserOut
  sync.onRatio = onRatio
  sync.onDataUpdated = onDataUpdated
  sync.connect()

  windowResized()
  window.addEventListener('resize', windowResized)
  window.addEventListener('keydown', onKeyDown)
  window.addEventListener('touchstart', toggleDebug)

  requestAnimFrame animate

onRatio = (ratio) ->
  skeleton.dataRatio = ratio
  skeleton.resize()
  console.log 'ratio set to '+ ratio

onUserIn = (userId) ->
  console.log "user #{userId} entered"

onUserOut = (userId) ->
  console.log "user #{userId} exited"

onDataUpdated = () ->
  perso.setFromSkeleton skeleton

onKeyDown = (ev) ->
  if ev.keyCode == 83 # s
    toggleDebug()

toggleDebug = () ->
  debug = !debug
  skeleton.setDebug debug
  perso.setDebug debug

windowResized = (ev) ->
  sw = window.innerWidth*window.devicePixelRatio
  sh = window.innerHeight*window.devicePixelRatio
  renderer.resize sw,sh
  renderer.view.style.width = window.innerWidth + 'px'
  renderer.view.style.height = window.innerHeight + 'px'
  if skeleton
    skeleton.resize()
    skeleton.view.position.x = sw * 0.5
    skeleton.view.position.y = sh * 0.5
    perso.view.position.x = skeleton.view.position.x
    perso.view.position.y = skeleton.view.position.y

animate = ->
  requestAnimFrame animate
  skeleton.update()
  perso.setFromSkeleton skeleton
  perso.update()
  renderer.render stage

setup()
