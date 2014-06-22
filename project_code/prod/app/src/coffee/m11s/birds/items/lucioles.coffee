class mk.m11s.birds.Lucioles
  
  constructor : (@symbol, @leftHand, @rightHand) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0
    @leftHandLucioles = []
    @rightHandLucioles = []
    @leavingLucioles = []
    @timeBetweenNewLucioles = 625 * 4.3 * 2
    @timeSinceLastLuciole = 0
    @addLuciole @leftHand
    @bDoubleHanded = false
    @bLeaving = false
    @timeBetweenRemoveLucioles = 625
    @timeSinceLastLucioleRemoved = 0

    @velTracker = new mk.helpers.JointVelocityTracker [@leftHand, @rightHand] 

    @sfx = mk.Scene::sfx.play 'lucioleloop'
    @sfx.volume(0) if @sfx

  clean : ->
    @sfx.stop()

  addLuciole : (hand) ->
    l = @symbol.place()
    rngk = 'addluciole'
    l.scaling = rng(rngk)*0.5 + 0.5
    l.position.x = rng(rngk)*window.viewport.width
    l.position.y = -window.viewport.height*0.5
    @view.addChild l
    @leftHandLucioles.push 
      view : l
      initP : l.position
      ang : rng(rngk)*Math.PI
      dist : rng(rngk)*150 + 15
      hand : hand
      speed : 0
      dspeed : rng(rngk)*0.005 + 0.001
    return

  addRightHand : () ->
    half = Math.floor(@leftHandLucioles.length / 2)
    @rightHandLucioles = @leftHandLucioles.splice 0, half
    for l in @rightHandLucioles
      l.hand = @rightHand 
      l.speed = 0.0005
    @bDoubleHanded = true

  leave : () ->
    @bLeaving = true
    @leaveLuciole()

  leaveLuciole : () ->
    for hand in [@rightHandLucioles, @leftHandLucioles]
      if hand.length > 0
        l = hand.shift()
        l.speed = 1
        @leavingLucioles.push l

  updateSFXVolume : ->
    @velTracker.update()
    v = @velTracker.get(0)+@velTracker.get(1)
    vol = Math.min 1, v / 500
    @sfx.volume vol

  update : (dt) ->
    @updateSFXVolume()

    if @bLeaving
      @timeSinceLastLucioleRemoved += dt
      if @timeSinceLastLucioleRemoved > @timeBetweenRemoveLucioles
        @timeSinceLastLucioleRemoved -= @timeBetweenRemoveLucioles
        @leaveLuciole()
    else
      @timeSinceLastLuciole += dt
      if @timeSinceLastLuciole > @timeBetweenNewLucioles
        @timeSinceLastLuciole -= @timeBetweenNewLucioles
        @addLuciole @leftHand
        if @bDoubleHanded
         @addLuciole @rightHand
    @updateLuciole(l, dt) for l in @leftHandLucioles
    @updateLuciole(l, dt) for l in @rightHandLucioles
    for l in @leavingLucioles
      l.view.position.x += (l.hand.x-l.view.position.x)*0.0001*dt
      l.view.position.y -= l.speed
      l.speed *= 1.01
    return
  
  updateLuciole : (l, dt) ->
    l.speed += (l.dspeed-l.speed) * 0.001 * dt
    l.ang += dt * l.speed
    p =
      x : Math.cos(l.ang)*l.dist
      y : Math.sin(l.ang)*l.dist
    p.x += l.hand.x
    p.y += l.hand.y
    l.view.position.x += (p.x-l.view.position.x) * l.speed * dt
    l.view.position.y += (p.y-l.view.position.y) * l.speed * dt
    return