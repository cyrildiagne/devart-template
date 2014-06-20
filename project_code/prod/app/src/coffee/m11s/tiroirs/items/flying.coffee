class mk.m11s.tiroirs.Flying extends mk.helpers.Flying

  constructor : (@item, id, opt) ->
    super @item, id, opt

    @timeSinceRandomPos = 0
    @timeBeforeNextRandomPos = 0
    @firstFlight = true

    @bFlyingToDrawer = false
    @onReachedDrawerCallback = null
    @speed = 0.003
    @scale = 1
    @flyAwayVelocity = null

  randomPos: ->
    x = (rng(@rngk)-0.5)*400
    y = (rng(@rngk)-0.5)*600 - 200
    if @firstFlight
      @firstFlight = false
      y = (rng(@rngk)-0.5)*100 - 500
    @dest = new paper.Point x,y
    @timeBeforeNextRandomPos = rng(@rngk) * 2000 + 200

  flyToDrawer: (@drawer, @onReachedDrawerCallback)->
    @bFlyingToDrawer = true
    if !@isFlying 
      @flyAwayVelocity = new paper.Point
        x : (rng('flytdr')-0.5)*5#window.viewport.width,
        y : -10#-0.5*window.viewport.height
      @start()
      delayed 4000, => @onReachedDrawerCallback()

  update: (dt) ->
    if !@isFlying then return

    if @flyAwayVelocity

      @velocity = @flyAwayVelocity

    else if @bFlyingToDrawer

      t = @drawer.view.position
      dist = t.subtract(@view.position)
      dist.y -= 10
      @velocity.x = dist.x * @speed * dt
      @velocity.y = dist.y * @speed * dt
      dx = dist.x
      dy = dist.y
      if dx*dx + dy*dy < 10 * 10
        if @onReachedDrawerCallback
          @onReachedDrawerCallback()
          return
      @scale *= 0.97
      @view.scaling = @scale
      if @scarf
        @scarf.scarf1.view.scaling = @scarf.scarf2.view.scaling = @scale
      else if @item
        @item.view.scaling = @scale
    else
      @timeSinceRandomPos+=dt
      if @timeSinceRandomPos > @timeBeforeNextRandomPos
        @timeSinceRandomPos -= @timeBeforeNextRandomPos
        @randomPos()
      @velocity = @dest.subtract(@pos).multiply(1.5/1000*dt)
      if @item
        @item.rotation += (@velocity.x * 4 - @item.rotation) * 0.1
        
    super dt