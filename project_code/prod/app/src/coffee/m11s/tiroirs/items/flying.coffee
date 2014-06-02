class mk.m11s.tiroirs.Flying extends mk.helpers.Flying

  constructor : (@item, id, opt) ->
    super @item, id, opt

    @timeSinceRandomPos = 0
    @timeBeforeNextRandomPos = 0

  randomPos: ->
    @dest = new paper.Point (rng(@rngk)-0.5)*400, (rng(@rngk)-0.5)*600 - 200
    @timeBeforeNextRandomPos = rng(@rngk) * 2000 + 200

  update: (dt) ->
    if !@isFlying then return
    @timeSinceRandomPos+=dt
    if @timeSinceRandomPos > @timeBeforeNextRandomPos
      @timeSinceRandomPos -= @timeBeforeNextRandomPos
      @randomPos()
    @velocity = @dest.subtract(@pos).multiply(1.5/1000*dt)
    if @item
      @item.rotation += (@velocity.x * 4 - @item.rotation) * 0.1
    super dt