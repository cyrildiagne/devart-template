class mk.m11s.birds.Bird extends mk.helpers.Flying

  constructor : (@item, id, wingColor) ->
    rngk = 'Bird' + id
    @item.pivot = new paper.Point 0, -6
    @scale = rng(rngk) * 0.3 + 0.6
    @speed = rng(rngk) * 0.6 + 0.7
    @distToLand = 10
    @distToFly = 30
    super @item, id, 
      color1 : wingColor
      color2 : wingColor
      wingWidth : 270
      wingHeight : 25
      wingAttachWidth : 25
      velocity : new paper.Point 0,0#3+rng(rngk)*2, 0
      wingSpeed : @speed
      pos : new paper.Point -600, (rng(rngk)-0.5) * 800 - 50
      v1length : 180
    @speed *= @speed * 0.002
    @bFlyingToBranch = false

  flyToBranch : (@target) ->
    @bFlyingToBranch = true
    if !@isFlying
      @start()

  land : () ->
    if @isFlying
      @stop()
    @bFlyingToBranch = false

  update: (dt) ->
    t = @target.pos.add(@target.ref.position)
    t.y -= 20
    dist = t.subtract(@view.position)
    if @bFlyingToBranch
      @velocity.x = dist.x * @speed * dt
      @velocity.y = dist.y * @speed * dt
      if @velocity.x < 0 && @view.scaling.x < 0
        @view.scaling = new paper.Point @scale, @scale
      else if @velocity.x > 0 && @view.scaling.x > 0
        @view.scaling = new paper.Point -@scale, @scale
      if dist.length < @distToLand
        @land()
        @view.position = t
    else
      if dist.length > @distToFly
        @flyToBranch @target
      else
        @view.position.x += (t.x-@view.position.x)*0.01*dt
        @view.position.y += (t.y-@view.position.y)*0.007*dt
    super dt