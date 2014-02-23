stage = null
renderer = null
skeleton = null
sync = null
perso = null

setup = ->
  stage = new PIXI.Stage(0xFFFFFF)
  renderer = PIXI.autoDetectRenderer(window.innerWidth, window.innerHeight)
  document.body.appendChild(renderer.view)

  skeleton = new Skeleton()
  stage.addChild skeleton.view

  sync = new SkeletonSync skeleton
  sync.onUserIn = onUserIn
  sync.onUserOut = onUserOut
  sync.onRatio = onRatio
  sync.onDataUpdated = onDataUpdated

  perso = new Perso()
  perso.setFromSkeleton skeleton
  stage.addChild perso.view

  windowResized()
  window.addEventListener('resize', windowResized)

  requestAnimFrame animate

onRatio = (ratio) ->
  skeleton.dataRatio = ratio
  skeleton.resize()

onUserIn = (userId) ->
  console.log "user #{userId} entered"

onUserOut = (userId) ->
  console.log "user #{userId} exited"

onDataUpdated = () ->
  perso.setFromSkeleton skeleton

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
  perso.update()
  renderer.render stage

setup()
