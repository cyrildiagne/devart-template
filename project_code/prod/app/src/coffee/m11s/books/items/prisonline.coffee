class mk.m11s.books.PLine

  constructor : (@jnt, @side) ->
    @length = 50
    @path = new paper.Path()
    @path.strokeWidth = 8
    @path.strokeCap = 'round'
    @path.strokeColor = mk.Scene::settings.getHexColor 'cream'
    @path.segments = [
      [@jnt.x,@jnt.y]
      [window.viewport.width*rng('t'), -window.viewport.height*0.5]
    ]
    @path.z = 0

    @bUpdate = 0

    @speed = rngi('bline', 6, 15) * @side

    @numUpdates = 10
    @bAdd = 0

    @velX = 0
    @velY = 0

    @jntPrev = new paper.Point()

  addNew : ->
    @path.add @jnt
    lp = @path.segments.last().point
    lp.velX = @velX #(@jnt.x - @jntPrev.x) * 0.25
    lp.velY = @velY #(@jnt.y - @jntPrev.y) * 0.25
    if @path.segments.length > @length
      @path.removeSegment(0)
    @path.smooth()

  update : (dt) ->
    p = @path
    p.x = @jnt.x
    p.y = @jnt.y


class mk.m11s.books.PLines
  constructor : (@joints, @side) ->
    @view = new paper.Group()
    @view.transformContent = false

    sw = 8
    @lines = []
    for j in @joints
      line = new mk.m11s.books.PLine j, @side
      s = line.speed
      @lines.push line

    @paths = []
    # @addPath()

  update : (dt) ->
    for line in @lines
      line.update(dt)


class mk.m11s.books.PrisonLines
  constructor : (rightJnts, leftJnts, zIndex=9999) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = zIndex

    @rightLines = new mk.m11s.books.PLines rightJnts, 1
    @view.addChild @rightLines.view

    @leftLines = new mk.m11s.books.PLines leftJnts, 1
    @view.addChild @leftLines.view

    console.log 'created'

  update : (dt) ->
    @rightLines.update dt
    @leftLines.update dt
