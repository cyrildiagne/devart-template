class mk.m11s.books.TrailPath
  
  constructor : (@trail1, @trail2, @color) ->
    @path = new paper.Path()
    @path.windingRule = 'nonzero'
    @path.fillColor = mk.Scene::settings.getHexColor @color#['lightBlue', 'blue', 'cream'].random()
    @path.fillColor = '#18181b'
    @path.z = 0
    # @path.fillColor = new paper.Color(Math.random())

  update : (dt) ->
    segs1 = @trail1.path.segments
    segs2 = @trail2.path.segments
    total = segs1.length + segs2.length
    @path.add [0,0] while @path.segments.length < total
    for i in [0...segs1.length]
      s = segs1[i]
      ps = @path.segments[i]
      ps.point.x = s.point.x
      ps.point.y = s.point.y
      ps.handleIn = s.handleIn
      ps.handleOut = s.handleOut
    for i in [0...segs2.length]
      j = segs2.length - i - 1
      s = segs2[j]
      ps = @path.segments[segs1.length+i]
      ps.point.x = s.point.x
      ps.point.y = s.point.y
      ps.handleIn = s.handleIn
      ps.handleOut = s.handleOut
    # @path.smooth()


class mk.m11s.books.TrailLine

  constructor : (@jnt, @side) ->
    @length = 50
    @path = new paper.Path()
    @path.strokeWidth = 8 #@jnt.radius + 5
    @path.strokeCap = 'round'
    # @path.strokeColor = mk.Scene::settings.getHexColor 'blue'
    @path.strokeColor = 'white'
    # @path.visible = false
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
    # @path.strokeWidth = (Math.abs(lp.velY)+Math.abs(lp.velX)) * 4 + 15
    if @path.segments.length > @length
      @path.removeSegment(0)
    @path.smooth()

  update : (dt) ->
    p = @path

    @velX += ((@jnt.x - @jntPrev.x) * 0.25 - @velX) * 0.0025 * dt
    @velY += ((@jnt.y - @jntPrev.y) * 0.25 - @velY) * 0.0025 * dt

    if @bAdd++ > @numUpdates
      @addNew()
      @bAdd = 0

    if p.segments.length
      for s in p.segments
        s.point.x += s.point.velX + @speed
        s.point.y += s.point.velY

      p.segments.last().point.x = @jnt.x
      p.segments.last().point.y = @jnt.y
      p.segments.last().handleIn = null
      p.segments.last().handleOut = null

    @jntPrev.x = @jnt.x
    @jntPrev.y = @jnt.y
      # if p.segments.length > 1
      #   p.segments[0].point.x += (p.segments[1].point.x - p.segments[0].point.x) * 0.4
      #   p.segments[0].point.y += (p.segments[1].point.y - p.segments[0].point.y) * 0.4


class mk.m11s.books.Lines
  constructor : (@joints, @side) ->
    @view = new paper.Group()
    @view.transformContent = false

    sw = 8
    @lines = []
    for j in @joints
      line = new mk.m11s.books.TrailLine j, @side
      s = line.speed
      # line.path.strokeWidth = (sw+=3)
      @lines.push line
      # line2 = new mk.m11s.books.TrailLine j, @side
      # line2.speed = s+0.1
      # line2.path.strokeWidth = (sw+=3)
      # @lines.push line2

    @paths = []
    @addPath()

  addPath : ->
    @paths = []
    colors = ['lightBlue']
    for i in [0...@lines.length-1] #by 2
      p = new mk.m11s.books.TrailPath @lines[i], @lines[i+1], colors[i%colors.length]
      @view.addChild @lines[i].path
      @view.addChild p.path
      @paths.push p
    @view.addChild @lines.last().path

  update : (dt) ->
    for line in @lines
      line.update(dt)

    p.update() for p in @paths
    # console.log @line.path.segments


class mk.m11s.books.HideShape
  constructor : (@jnts) ->
    @view = new paper.Path()
    @view.z = -3332
    @view.fillColor = '#18181b'
    @view.windingRule = 'nonzero'
    for j in @jnts
      @view.add [j.x, j.y]
  update : (dt) ->
    for i in [0...@jnts.length]
      @view.segments[i].point.x = @jnts[i].x
      @view.segments[i].point.y = @jnts[i].y

class mk.m11s.books.LineWaves
  constructor : (rightJnts, leftJnts, zIndex=9999) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = zIndex

    @rightLines = new mk.m11s.books.Lines rightJnts, 1
    @view.addChild @rightLines.view

    @leftLines = new mk.m11s.books.Lines leftJnts, -1
    @view.addChild @leftLines.view

    console.log 'created'

  update : (dt) ->
    @rightLines.update dt
    @leftLines.update dt