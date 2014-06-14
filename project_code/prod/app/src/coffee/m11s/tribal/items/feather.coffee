class mk.m11s.tribal.Feather

  constructor: (@symbol, @j1, @j2, @pct) ->
    @view = @symbol.place()
    @view.transformContent = false
    @view.pivot = new paper.Point(-@view.bounds.width*0.5, 0)
    @view.z = 0
    @follower = new mk.helpers.PartEdgeFollower @view, @j1, @j2, @pct
    @speed = 0
    @offset = 0
    @defom = false

  setColor: (color) ->
    @view.fillColor = color

  setSpeed : (speed) ->
    @speed += (speed - @speed) * 0.03

  update: (dt) ->
    @follower.update()
    @view.rotate( @speed )
    @view.z += 10
    if @deform
      @view.scaling = @speed / 9



class mk.m11s.tribal.FeatherGroup

  constructor: (@settings, @j1, @j2, @num=8, @spacingScale=1) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0
    @colors = [
      @settings.palette.skin,
      @settings.palette.cream,
      @settings.palette.beige,
      @settings.palette.red,
      @settings.palette.lightRed
    ]
    @featherSymbols = {}
    @feathers = []
    @addFeaters @num

    @prev = 
      p1 : new paper.Point(@j1.x, @j1.y)
      p2 : new paper.Point(@j2.x, @j2.y)

  clean : ->
    for f in @feathers
      f.remove()

  addFeaters: (num) ->
    for i in [1..num]
      color = @colors.seedRandom 'addFeaters'+num
      featherSym = @getFeatherSymbol 90, color
      feather = new mk.m11s.tribal.Feather featherSym, @j1, @j2, (i-0.5)/num * @spacingScale
      feather.view.rotate i*(25-num) - 180
      feather.view.scale 1 - (i/num)*0.5
      feather.setColor color
      # @view.addChild feather.view
      @feathers.push feather

  getFeatherSymbol: (width, color) ->
    vectorIn  = new paper.Point({ angle: 0, length: width / 3 })
    vectorEnd = new paper.Point({ angle: 0, length: width / 8 })
    x = 0
    y = 0
    path = new paper.Path()
    path.segments = [
      [[x,     y],  null,                   vectorIn.rotate(-15)],
      [[width, y],  vectorEnd.rotate(-90),  vectorEnd.rotate(90)],
      [[x,     y],  vectorIn.rotate(15),    null]
    ];
    # path.position = new paper.Point(path.bounds.width*0.5, 150)
    path.fillColor = "#"+color.toString(16)
    return new paper.Symbol(path)

  update: (dt) ->

    d1x = @j1.x - @prev.p1.x
    d1y = @j1.y - @prev.p1.y
    distSquared = d1x * d1x + d1y * d1y
    speed = Math.min(distSquared / 5, 10)

    for f in @feathers
      f.setSpeed(speed)
      f.update dt

    # @view.z = @j1.z * (1-@pct) + @j2.z * (@pct)

    @prev.p1.x = @j1.x
    @prev.p1.y = @j1.y