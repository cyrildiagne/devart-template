# class mk.m11s.tech.Line
#   constructor : (@j1, @j2, @pct) ->
#     @path = new paper.Path()
#     @path.segments = [[0,0],[0,0]]
#     @path.strokeWidth = 5
#     @path.strokeCap = 'round'
#     @path.strokeColor = 'red'
#     @pos = new paper.Point(0,0)
#     @dest = new paper.Point(0,0)
#     @speed = 0.0001
#     @setDest()
#   update : (dt) ->
#     @setDest()
#     @pos.x += (@dest.x - @pos.x ) * @speed * dt
#     @pos.y += (@dest.y - @pos.y ) * @speed * dt
#     @path.segments[0].point.x = @dest.x
#     @path.segments[0].point.y = @dest.y
#     @path.segments[1].point.x = @pos.x
#     @path.segments[1].point.y = @pos.y
#     @path.strokeColor.brightness = Math.random()
#   setDest : ->
#     @dest.x = @j1.x * @pct + @j2.x * (1-@pct)
#     @dest.y = @j1.y * @pct + @j2.y * (1-@pct)


class mk.m11s.tech.TrailLine

  colors : []

  constructor : (@j1, @j2, @pct) ->
    @length = 15
    @path = new paper.Path()
    @path.strokeWidth = 4
    @path.strokeCap = 'round'
    @path.strokeColor = mk.m11s.tech.TrailLine::colors.random()

    @bUpdate = 0
    @brightnessInterval()

    @numUpdates = 2
    @bAdd = 0

    @prev = new paper.Point()
    @pos = new paper.Point()

  brightnessInterval : =>
    @path.strokeColor = mk.m11s.tech.TrailLine::colors.random()
    delayed rng('t')*600+300, @brightnessInterval

  addNew : ->
    @path.add @pos
    if @path.segments.length > @length
      @path.removeSegment(0)
    @path.smooth()

  update : (dt) ->
    @pos.x = @j1.x * @pct + @j2.x * (1-@pct)
    @pos.y = @j1.y * @pct + @j2.y * (1-@pct)

    p = @path
    if p.segments.length
      p.segments.last().point.x = @pos.x
      p.segments.last().point.y = @pos.y

      if p.segments.length > 1
        p.segments[0].point.x += (p.segments[1].point.x - p.segments[0].point.x) * 0.4
        p.segments[0].point.y += (p.segments[1].point.y - p.segments[0].point.y) * 0.4

    if @bAdd++ > @numUpdates
      @addNew()
      @bAdd = 0


class mk.m11s.tech.Trail
  constructor : (@parts, @head, @pelvis) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 9999

    # parts = @parts.slice(0)
    # parts.push
    #   joints : [@head.joints[0], @pelvis.joints[0]]

    @visible = @view.visible = false

    for c in ['skin','cream','red','lightRed']
      color = new paper.Color mk.Scene::settings.getHexColor(c)
      mk.m11s.tech.TrailLine::colors.push color

    @lines = []
    @numLinePerPart = 7
    for p in parts
      for i in [1...@numLinePerPart]
        # console.log p.joints[0]
        line = new mk.m11s.tech.TrailLine p.joints[0], p.joints[1], i * (1/@numLinePerPart)
        # line.path.strokeColor = @colors.seedRandom 'triblines'
        @lines.push line
        @view.addChild line.path

  update : (dt) ->
    if @visible
      for line in @lines
        line.update(dt)

  toggleStrombo : ->

  
  setLength : (length) ->
    l.length = length for l in @lines

  setVisible : (@visible) ->
    @view.visible = @visible
    if !@visible
      for line in @lines
        line.path.removeSegments 0, line.path.segments.length-1