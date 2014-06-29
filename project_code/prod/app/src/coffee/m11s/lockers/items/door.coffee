class mk.m11s.lockers.Door

  constructor: (w, h) ->
    @w = w
    @h = h

    @path = new paper.Path()
    @path.transformContent = false
    @path.fillColor = mk.Scene::settings.getHexColor 'background'
    @initBrightness = @path.fillColor.brightness

    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.addChild @path
    @view.scaling = new paper.Point 1,1

    @pers = 150
    @light = 0.002

    @maxOpenness = 0.1

    @reset()
    @isOpening = false
    @isTurning = false

  update : (dt) ->
    if @isTurning# && !@isLocked
      @updateTurn dt

  updateTurn : (dt) ->
    if @isTurning
      p1 = @path.segments[1].point
      p2 = @path.segments[2].point
      scaleX = @view.scaling.x
      if @isOpening
        @path.fillColor.brightness += @light
        p1.y += (- @pers - p1.y) * 0.005 * dt
        p2.y += (@h + @pers - p2.y) * 0.005 * dt
        scaleX += (0-scaleX)*0.05
        if scaleX < @maxOpenness
          # @isOpening = false
          @isTurning = false
          @isOpen = true
          # if @openCallback
          #   @openCallback()
      else
        scaleX += (1.05-scaleX)*0.05
        @path.fillColor.brightness += (@initBrightness - @path.fillColor.brightness)*0.07
        p1.y += (0 - p1.y) * 0.002 * dt
        p2.y += (@h - p2.y) * 0.002 * dt
        if scaleX > 1
          @isTurning = false
          @isClosed = true
          @closeCallback()
      @view.scaling = new paper.Point scaleX,1

  open : (@maxOpenness=0.1)->
    @reset()
    @isOpening = true
    @isTurning = true
    @isClosed = false

  close : ->
    @isOpen = false
    @isOpening = false
    @isTurning = true

  reset : ->
    @view.scaling = new paper.Point 1,1
    @h1 = true
    @path.segments = [
      [0,  0]
      [@w, 0]
      [@w, @h]
      [0,  @h]
    ]
    @path.fillColor.brightness = @initBrightness
    @isOpen = false
    @isClosed = true
    @isOpening = true
    @isTurning = true


class mk.m11s.lockers.DoorBackground

  constructor : (@head) ->

    @numStairs = 10
    @stairHeight = 60
    @perspective = 60

    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0

    @w = window.viewport.width
    @h = window.viewport.height

    @mask = new paper.Path.Rectangle [-@w*0.5, -@h*0.5], [@w, @h]
    @mask.fillColor = 'red'
    @view.addChild @mask

    @bg = new paper.Path.Rectangle [-@w*0.5, -@h*0.5], [@w, @h]
    @bg.fillColor = mk.Scene::settings.getHexColor 'lightBlue'
    @view.addChild @bg

    @stairs = []
    @addStairs()

    @view.clipped = true

  addStairs : ->
    @colors = ['cream', 'blue']
    @colors[i] = mk.Scene::settings.getHexColor @colors[i] for i in [0..1]
    for i in [0...@numStairs]
      s = new paper.Path.Rectangle [-@w*0.5,0], [@w, @stairHeight]
      s.fillColor = @colors[i%2]
      # s.position.y = window.viewport.height * 0.5 - i * @stairHeight - 200
      # s.position.x = -i * 60 - 100
      @view.addChild s
      @stairs.push s
    @update()

  update : (dt) ->
    for i in [@numStairs-1..0] by -1
      s = @stairs[i]
      j = (@numStairs-i)
      s.position.y = window.viewport.height * 0.5 - j * @stairHeight - 200
      s.position.x = -j * @perspective - 100
      offY = @head.y * 0.01 * j
      offY = Math.min(offY, 0)
      s.position.x += - @head.x * 0.5 * (j/@stairs.length)
      s.position.y += - offY
    return


class mk.m11s.lockers.DoorOpen
  
  constructor : (@head, @animComplete) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.z = -9999 + Math.random()

    @bg = new mk.m11s.lockers.DoorBackground @head
    @view.addChild @bg.view
    # @bg = mk.Scene::assets['door'].place()
    # @view.addChild @bg

    @particles = []
    @particlesView = new paper.Group()
    @particlesView.transformContent = false
    @view.addChild @particlesView
    
    @timeSinceParticles = 0
    @timeBeforeNextParticles = 0
    @addParticlesTime = 0

    @door = new mk.m11s.lockers.Door @bg.w+10, @bg.h+10
    @door.view.position.x = -@door.view.bounds.width*0.5
    @door.view.position.y = -@door.view.bounds.height*0.5
    @door.openCallback = @doorOpened
    @door.closeCallback = @doorClosed
    @view.addChild @door.view

    # @popupAndShineYouBeautiful()

  addParticle : ->
    offY = (rng('ap')-0.5) * @bg.h * 0.5
    if @isInside
      offY *= 0.5
      offY -= 400 
    p = new paper.Path.Circle
      center : 
        # x : -@bg.bounds.width*0.5+15
        # y : (rng('ap')-0.5) * @bg.bounds.height * 0.5
        x : -@bg.w*0.5+15
        y : offY
      radius : 10 + rng('ap') * 15
      fillColor : mk.Scene::settings.getHexColor ['red', 'lightRed', 'blue', 'lightBlue'].seedRandom('adp')
    p.speed = 0.4 + rng('ap') * 0.2
    p.rspeed = (1 + rng('ap')*3)
    if rng('ap') > 0.5 then p.rspeed *= -1
    p.segments[0].handleIn = p.segments[0].handleOut = null
    p.segments[0].point.x -= 10
    p.segments[1].point.y += 5
    p.segments[2].handleIn = p.segments[2].handleOut = null
    p.segments[3].point.y -= 5

    @particlesView.addChild p
    @particles.push p

  removeParticle : (p) ->
    p.remove()
    @particles.splice @particles.indexOf(p),1

  popupAndShineYouBeautiful : ->

    if @door.isClosed
      @view.scaling = rng('puasyb') * 0.30 + 0.30
      @view.position = 
        x : (-0.3) * window.viewport.width * rng('test')
        y : (-0.75+@view.scaling.x) * window.viewport.height * rng('test')
      @door.open()

    @addParticlesTime += 3000

  doorOpened : =>
    console.log 'door opened'

  doorClosed : =>
    setTimeout =>
      @animComplete @
    , 2000

  setupInside : ->
    @view.scaling = 1
    @view.position = 
      x : 0
      y : 0
    @door.open 0.05
    @isInside = true

  clean : ->
    p.remove() for p in @particles
    @view.remove()

  update : (dt) -> 
    @bg.update dt
    @door.update dt

    rmParticles = []

    if !@door.isClosed and @addParticlesTime > 0 
      @addParticlesTime -= dt
      @timeSinceParticles += dt
      if @timeSinceParticles > @timeBeforeNextParticles
        @timeSinceParticles -= @timeBeforeNextParticles
        @timeBeforeNextParticles = rng('PileUpdate') * 60 + 40
        @addParticle()
      if !@isInside && @door.isOpen && @addParticlesTime <= 0
        @door.close()

    for p in @particles
      if p.position.x < 3500
        p.speed += 0.01
        p.position.x += p.speed*dt
        p.position.y -= p.position.x * 0.01
        p.rotation += p.rspeed
      else rmParticles.push p

    @removeParticle p for p in rmParticles

