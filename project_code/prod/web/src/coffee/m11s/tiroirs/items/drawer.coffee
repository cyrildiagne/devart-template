class mk.m11s.tiroirs.Drawer

  constructor: (@symbol, @part, @settings, opt) ->
    @rngk = 'Drawer'+@part

    @view = new paper.Group()
    # @view.addChild @symbol.place()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    
    # @side = if rng(@rngk) > 0.5 then 1 else -1
    @side = 1
    @left = @right = @front = @back = @bottom = null
    @setup()

    @view.scale opt.scale

    @follower = new mk.helpers.PartFillFollower @view, @part, opt.weights, opt.z + 100

    @maxOpenness = 60

    @openness = 0
    @time = 0
    @timeoffset = rng('Drawer') * Math.PI

  setup : ->
    @setupBack 'darkGray'
    # @setupBottom 'beige'
    @setupSides 'beige'
    @setupFront 'cream', 'red'

  setupFront : (color, handleColor) ->
    @front = new paper.Group
    @front.pivot = new paper.Point 55,30
    @front.transformContent = false

    @frontP = new paper.Path.Rectangle
      point : [0, 0]
      size  : [110, 60]
      fillColor : '#' + @settings.palette[color].toString 16
    @front.addChild @frontP

    @handle = new paper.Path.Circle
      center : [50, 30]
      radius : 8
      fillColor : '#' + @settings.palette[handleColor].toString 16
    @front.addChild @handle

    @view.addChild @front

  setupBack : (color) ->
    @back = new paper.Path.Rectangle
      point : [-55, -30]
      size  : [110, 60]
      fillColor : '#000'# + @settings.palette[color].toString 16
    @view.addChild @back

  setupBottom : (color) ->
    @bottom = new paper.Path
    @bottom.add new paper.Point() for i in [0...4]
    @bottom.fillColor = '#' + @settings.palette[color].toString 16
    @view.addChild @bottom

  setupSides : (color) ->
    @left = new paper.Path
    @left.add new paper.Point() for i in [0...4]
    @left.fillColor = '#' + @settings.palette[color].toString 16
    @view.addChild @left

    @right = new paper.Path
    @right.add new paper.Point() for i in [0...4]
    @right.fillColor = '#' + @settings.palette[color].toString 16
    @view.addChild @right

  updateOpenness : ->
    # @bottom.segments[0].point = @front.bounds.bottomLeft
    # @bottom.segments[1].point = @front.bounds.bottomRight
    # @bottom.segments[2].point = @back.bounds.bottomRight
    # @bottom.segments[3].point = @back.bounds.bottomLeft

    @left.segments[0].point = @front.bounds.topLeft
    @left.segments[1].point = @front.bounds.bottomLeft
    @left.segments[2].point = @back.bounds.bottomLeft
    @left.segments[3].point = @back.bounds.topLeft

    @right.segments[0].point = @front.bounds.topRight
    @right.segments[1].point = @front.bounds.bottomRight
    @right.segments[2].point = @back.bounds.bottomRight
    @right.segments[3].point = @back.bounds.topRight

  update : (dt) ->
    @follower.update()
    @time += dt
    @openness = Math.sin(@time / 400 + @timeoffset) * 0.5 + 0.5
    @front.position.x = @openness * @maxOpenness * @side
    @front.position.y = @openness * @maxOpenness * 0.5
    # console.log @openness
    @updateOpenness()