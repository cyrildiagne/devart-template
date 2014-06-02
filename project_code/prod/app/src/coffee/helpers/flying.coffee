class mk.helpers.Wing

  constructor : (opt) ->

    defaults =
      v1length : 250
      v2length : 150

    for k, v of defaults
      if !opt[k] then opt[k] = v

    @speed = opt.speed
    @path = new paper.Path()
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
  
  update : (time) ->
    time *= @speed
    a = @a = Math.cos(time) * 65 + 15
    p = @path.segments
    p[1].handleIn  = @vector.rotate(a+130)
    p[1].handleOut = @vector.rotate(a+110)
    p[1].point.y = Math.cos(time+1.4) * 240 + 50
    a2 = @a2 = Math.cos(time-7) * 50 - 10
    p[0].handleOut = @vector.rotate(-a2*1.2-85)
    p[2].handleIn  = @vector.rotate(-a2*1.1-35)

class mk.helpers.Flying

  constructor : (@item, id, opt) ->
    @rngk = 'Flying'+id

    @wingWidth  = 400
    @wingHeight = 20
    @wingAttachWidth = 0
    @wingSpeed  = 1
    @count      = 0
    @mouse      = new paper.Point()
    @pos        = new paper.Point()
    @velocity   = new paper.Point()
    @isFlying   = true

    @[k] = v for k, v of opt

    @view = new paper.Group()
    @view.z = 0
    @view.transformContent = false
    @view.position = @pos.clone()
    @view.pivot = new paper.Point(0, 0)

    @leftWing = new mk.helpers.Wing
      x : 0
      y : 0
      width : @wingWidth
      height : @wingHeight
      speed : @wingSpeed
      color : @color1
      wingAttachWidth : @wingAttachWidth
      v1length : opt.v1length
    @leftWing.path.scale -0.8, 0.8
    @leftWing.path.position.x = -@wingWidth*0.5*0.8*0.25
    @view.addChild @leftWing.path

    if @item
      @item.transformContent = false
      @item.position.x = -@item.pivot.x
      @item.position.y = -@item.pivot.y
      @view.addChild @item

    @rightWing = new mk.helpers.Wing 
      x : 0
      y : 0
      width : @wingWidth
      height : @wingHeight
      speed : @wingSpeed
      color : @color2
      wingAttachWidth : @wingAttachWidth
      v1length : opt.v1length
    @view.addChild @rightWing.path

  start: (pos) ->
    @isFlying = true
    if @item
      @item.remove()
    @view.addChild @leftWing.path
    if @item
      @view.addChild @item
    @view.addChild @rightWing.path
    if pos
      @pos = pos

  stop: () ->
    @isFlying = false
    @leftWing.path.remove()
    @rightWing.path.remove()

  update : (dt) ->
    if !@isFlying then return

    @pos = @pos.add @velocity
    
    @view.position = @pos.add new paper.Point(@leftWing.a*0.1, @leftWing.a2*0.3)
    
    @count += 0.15 + @velocity.length*0.015

    @leftWing.update @count
    @rightWing.update @count