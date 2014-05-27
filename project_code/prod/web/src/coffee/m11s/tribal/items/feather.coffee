class mk.m11s.tribal.Feather

  constructor: (@symbol, @j1, @j2, @pct) ->
    @view = @symbol.place()
    @view.transformContent = false
    @view.pivot = new paper.Point(-@view.bounds.width*0.5, 0)
    @follower = new mk.helpers.PartEdgeFollower @view, @j1, @j2, @pct
    @speed = 0

  setColor: (color) ->
    @view.fillColor = color

  update: (speed) ->
    @speed += (speed - @speed) * 0.03
    @follower.update()
    @view.rotate( @speed )


class mk.m11s.tribal.FeatherGroup

  constructor: (@settings, @j1, @j2, @num=8, @spacingScale=1) ->
    @view = new paper.Group()
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

  addFeaters: (num) ->
    for i in [1..num]
      color = @colors.seedRandom 'addFeaters'+num
      featherSym = @getFeatherSymbol 90, color
      feather = new mk.m11s.tribal.Feather featherSym, @j1, @j2, (i-0.5)/num * @spacingScale
      feather.view.rotate i*(25-num)
      feather.view.scale 1 - (i/num)*0.5
      feather.setColor color
      @view.addChild feather.view
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

  update: () ->

    d1x = @j1.x - @prev.p1.x
    d1y = @j1.y - @prev.p1.y
    distSquared = d1x * d1x + d1y * d1y
    speed = Math.min(distSquared / 5, 10)

    f.update(speed) for f in @feathers

    @prev.p1.x = @j1.x
    @prev.p1.y = @j1.y