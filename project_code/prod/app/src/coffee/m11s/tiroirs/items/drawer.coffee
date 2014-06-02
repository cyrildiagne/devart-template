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
    @dOpenness = 0
    @time = 0
    @isOpen = false
    @isChanging = false

  setup : ->
    if rng(@rgnk+'setup') > 0.3
      c1 = ['beige', 'cream']
    else c1 = ['lightBlue', 'blue']
    if @part.name is 'torso'
      c2 = ['red', 'darkGray']
    else c2 = ['darkGray', 'red']

    @setupBack c2[1]
    @setupSides c1[1]
    @setupFront c1[0], c2[0]

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
      fillColor : '#' + @settings.palette[color].toString 16
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

  toggle : ->
    if @isChanging
      return false
    if @isOpen then @dOpenness = 0
    else @dOpenness = 1
    @isOpen = !@isOpen
    @isChanging = true
    return true

  updateOpenness : ->
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
    @openness += (@dOpenness-@openness) * 0.005 * dt
    if @isChanging
      if Math.abs(@dOpenness-@openness) < 0.1
        @isChanging = false
    @front.position.x = @openness * @maxOpenness * @side
    @front.position.y = @openness * @maxOpenness * 0.5
    
    @updateOpenness()