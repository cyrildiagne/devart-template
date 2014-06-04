class mk.m11s.lockers.Pile

  constructor : (symbol, @color) ->

    @view = new paper.Group()
    @view.transformContent = false
    @view.position.x = 150
    @view.position.y = 300

    @view.z = -2000

    @pile = symbol.place()
    @view.addChild @pile

    @grains = []

    @timeSinceGrain = 0
    @timeBeforeNextGrain = 0
    @addGrainTime = 0

  addGrain : ->
    g = new paper.Path.Circle
      center : new paper.Point -(rng('pile')-0.5)*30*@pile.scaling.x, -900
      radius : 4
      fillColor : '#' + @color.toString 16
    @view.addChild g
    @grains.push g

  addSome : ->
    @addGrainTime += 1000

  update : (dt) ->

    if @addGrainTime > 0
      @addGrainTime -= dt

      @timeSinceGrain+=dt
      if @timeSinceGrain > @timeBeforeNextGrain
        @timeSinceGrain -= @timeBeforeNextGrain
        @timeBeforeNextGrain = rng('PileUpdate') * 60 + 40
        @addGrain()

    rmGrains = []
    for g in @grains
      if g.position.y < 0
        g.position.y += 0.6*dt
      else rmGrains.push g

    for g in rmGrains
      @pile.scale(1.009)
      @pile.position.y -= 0.1
      g.remove()
      @grains.splice @grains.indexOf(g),1