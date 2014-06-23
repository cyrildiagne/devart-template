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
    @view.z = 3000+rng(rngk)*2
    @speed *= 0.0015
    @bFlyingToBranch = false
    @bFlyingToDestination = false
    @destination = null
    mk.Scene::sfx.play 'bird'+rngi('ftb',1,3)

  flyToBranch : (@target) ->
    @bFlyingToBranch = true
    if !@isFlying
      @start()
      # console.log 'fly to branch'
      mk.Scene::sfx.play 'bird'+rngi('ftb',1,3)

  flyToHouse : (house, @goneHomeCallback) ->
    @bFlyingToDestination = true
    @bFlyingToBranch = false
    @speed *= 2.5
    @destination = house.view

  flyOut : (@goneHomeCallback, bForce=false) ->
    if @isFlying and !bForce then return

    # console.log 'fly out'

    @bFlyingToDestination = true
    @bFlyingToBranch = false
    x = 400+rng('flyout')*300#(rng('flyout')-5) * window.viewport.width
    if @target.pos.x < 0 then x *= -1
    y = @target.pos.y - 300 - rng('flyout') * 300#- window.viewport.height * 0.5
    @destination = 
      position : new paper.Point x,y

    if !bForce
      @start()
      mk.Scene::sfx.play 'bird'+rngi('ftb',1,3)
    # @speed *= 2.5

  land : () ->
    if @isFlying
      @stop()
    @bFlyingToBranch = false
    if @bFlyingToDestination
      @goneHomeCallback()
      @bFlyingToDestination = false

  hide : () ->
    @view.remove()

  update: (dt) ->
    if !@bFlyingToDestination and @target.scale < 0.3
      @flyOut(=>
        # @bFlyingToBranch = true
        @start()
        @bFlyingToBranch = true
      ,true)

    if @bFlyingToDestination
      t = @destination.position
    else 
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