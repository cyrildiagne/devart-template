class mk.m11s.birds.WildBird extends mk.helpers.Flying

  constructor : (@asset, @house, wingColor) ->
    rngk = 'wildbird'
    @item = @asset.place()
    @item.pivot = new paper.Point 0, -6
    super @item, rngk, 
      color1 : wingColor
      color2 : wingColor
      wingWidth : 270
      wingHeight : 25
      wingAttachWidth : 25
      velocity : new paper.Point 0,0
      v1length : 180
    @dest = null
    @stop()
    @view.visible = false
    @numUpdatesSinceDeparture = 0
    @scale = 0.6

  flyAway : () ->
    @speed = 0.0002
    @view.visible = true
    ang = (rng('flyaway')*180-90-90) / 180 * Math.PI
    dist = window.viewport.height
    @dest = new paper.Point
      x : Math.cos(ang) * dist
      y : Math.sin(ang) * dist
    @start()
    @pos.x = @view.position.x = @house.view.position.x
    @pos.y = @view.position.y = @house.view.position.y
    @numUpdatesSinceDeparture = 0
    mk.Scene::sfx.OiseauBranche_1.play()

  update: (dt) ->
    if @isFlying
      @speed *= 1.02
      if @numUpdatesSinceDeparture++ > 80
        console.log "stopped"
        @stop()
        @view.visible = false
      @velocity = @dest.subtract(@pos).multiply(@speed*dt)
      if @velocity.x < 0 && @view.scaling.x < 0
        @view.scaling = new paper.Point @scale, @scale
      else if @velocity.x > 0 && @view.scaling.x > 0
        @view.scaling = new paper.Point -@scale, @scale
    super dt