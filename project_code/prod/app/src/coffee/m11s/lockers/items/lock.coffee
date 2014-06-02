class mk.m11s.lockers.Lock

  constructor: (@symbol, @part, @seed) ->
    @item = @symbol.place()
    scale = rng(@seed)*0.5 + 0.3
    if @part.name is "torso"
      scale = rng(@seed)*0.8 + 0.8
    @item.scale scale

    @view = new paper.Group()
    @view.pivot = new paper.Point 0, 0
    @view.transformContent = false
    @view.addChild @item
    @view.z = 0
    weights = mk.helpers.getRandomWeights @part.joints, @seed
    @follower = new mk.helpers.PartFillFollower @view, @part, weights, rng(@seed) * 100 + 200

    @available = true
    @flying = false
    @out = false

  clean: ->
    @view.removeChildren()
    # @view.remove()

  breakFree: ->
    view = @view
    rngk = @seed+'breakFree'
    @velX = (rng(rngk)+1) / 20
    @velY = -(rng(rngk)+1) / 30
    @velRotation = (rng(rngk)+1) / 40
    @flying = true
    @follower = null

  update: (dt) ->
    if @flying
      @view.position.y += @velY * dt
      if @view.position.y < -500
        @out = true
        return
      @view.position.x += @velX * dt
      @view.rotate @velRotation * dt
      @velX *= 1.02
      @velY *= 1.04
      @velRotation *= 1.02
    else
      @follower.update()