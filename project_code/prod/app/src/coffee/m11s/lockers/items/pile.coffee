class mk.m11s.lockers.Tentacle

  constructor : (opt) ->

    defaults =
      v1length : 250
      v2length : 150
      speed : 0.003
      x : 0
      y : 0
      width : 400
      height : 20
      wingAttachWidth : 0

    for k, v of defaults
      if !opt[k] then opt[k] = v

    @speed = opt.speed
    @path = new paper.Path()
    @path.pivot = new paper.Point 0,0
    @path.transformContent = false
    @path.scale 0.25

    @vector = new paper.Point 
      angle: 45
      length: opt.v1length
    endVec = new paper.Point
      angle: 45
      length: opt.v2length
    @path.segments = [
      [opt.x, opt.y],
      [opt.x+opt.width, opt.y],
      [opt.x-opt.wingAttachWidth, opt.y+opt.height]
    ]
    @path.fillColor = opt.color
    @a = @a2 = 0

    @time = 0
  
  update : (dt) ->
    @time += dt * @speed
    a = @a = Math.cos(@time) * 45 + 15
    p = @path.segments
    p[1].handleIn  = @vector.rotate(a+130)
    p[1].handleOut = @vector.rotate(a+110)
    p[1].point.y = Math.cos(@time+1.4) * 220 + 50
    a2 = @a2 = Math.cos(@time-7) * 30 - 10
    p[0].handleOut = @vector.rotate(-a2*1.2-85)
    p[2].handleIn  = @vector.rotate(-a2*1.1-35)




class mk.m11s.lockers.Tentacles

  constructor : (@pile, @color) ->
    @view = new paper.Group()
    @view.pivot = new paper.Point 0,0
    @view.transformContent = false

    @tentacles = []


    time = 0
    for i in [0...3]
      color = new paper.Color @color
      color.brightness -= 0.05 + Math.random()*0.2
      ttcle = new mk.m11s.lockers.Tentacle
        color : color
      ttcle.path.scale  @pile.scaling.x * (0.5+(rng('ttcfl')-0.5) * 0.2)
      ttcle.path.rotate 90 + (rng('ttcfl')-0.5) * 5
      ttcle.path.position.y = 20 * @pile.scaling.x + (rng('ttcfl')-0.5) * 5
      ttcle.time = (time += Math.PI*2  / 3)
      @view.insertChild 0,ttcle.path
      @tentacles.push ttcle

    pw = @pile.bounds.width
    ph = @pile.bounds.height
    h = window.viewport.height

    @mask = new paper.Path.Rectangle [-pw*0.5,ph*0.5-h], [pw, h]
    @mask.transformContent = false
    @mask.pivot = new paper.Point 0,0
    @mask.fillColor = 'red'
    @mask.position.y -= 30
    @view.insertChild 0,@mask
    @view.clipped = true

  update : (dt, speed) ->
    ttcle.update dt for ttcle in @tentacles
    if @mask
      @mask.position.y += speed
      if @mask.position.y > 300
        @mask.remove()
        @mask = null
        @view.clipped = false




class mk.m11s.lockers.Pile

  SCALE_MAX_BEFORE_FLY : 2.5

  constructor : (@type) ->

    symbs = ['pile1', 'pile2', 'pile3']
    colors = ['beige', 'blue', 'lightRed']
    symbol = mk.Scene::assets[ symbs[@type] ]
    @color = mk.Scene::settings.getHexColor colors[@type]

    lightColors = ['cream', 'lightBlue', 'red']
    @lightColor = mk.Scene::settings.getHexColor lightColors[@type]

    @view = new paper.Group()
    @view.transformContent = false
    # @view.pivot = new paper.Point 0,0

    x = (rng('pile')*0.2+0.2) * window.viewport.width
    x *= (if rng('pile') > 0.5 then 1 else -1)
    @initX = @view.position.x = x
    # console.log (rng('pile')*0.2+0.2) * window.viewport.width
    # console.log rng('pile') > 0.5
    @view.position.y = 400 - @type * 120

    @view.z = -2000 - @type * 100 + Math.random()

    @pile = symbol.place()
    @pile.scaling = 0.5
    @view.addChild @pile

    @grains = []

    @timeSinceGrain = 0
    @timeBeforeNextGrain = 0
    @addGrainTime = 0

    @speed = 0
    @tentacles = null

  addGrain : ->
    g = new paper.Path.Circle
      center : new paper.Point -(rng('pile')-0.5)*30*@pile.scaling.x, -900
      radius : 3
      fillColor : @color
    @view.addChild g
    @grains.push g

  removeGrain : (g) ->
    @pile.scaling = @pile.scaling.x + 0.025
    @pile.position.y -= 0.25
    g.remove()
    @grains.splice @grains.indexOf(g),1
    if @pile.scaling.x > mk.m11s.lockers.Pile::SCALE_MAX_BEFORE_FLY && @grains.length is 0
      @fullCallback() if @fullCallback

  addSome : ->
    @addGrainTime += 1000

  fly : ->
    @tentacles = new mk.m11s.lockers.Tentacles @pile, @color
    @view.insertChild 0, @tentacles.view

  update : (dt) ->

    if @tentacles
      @speed += 0.025
      @tentacles.update dt, @speed
      # @view.position.x = @initX + Math.cos(window.currentTime) * 5 * @speed
      @view.position.y -= @speed
      return

    rmGrains = []

    if @addGrainTime > 0
      @addGrainTime -= dt
      @timeSinceGrain+=dt
      if @timeSinceGrain > @timeBeforeNextGrain
        @timeSinceGrain -= @timeBeforeNextGrain
        @timeBeforeNextGrain = rng('PileUpdate') * 60 + 40
        @addGrain()
    for g in @grains
      if g.position.y < 0
        g.position.y += 0.6*dt
      else rmGrains.push g

    @removeGrain g for g in rmGrains
      
    return