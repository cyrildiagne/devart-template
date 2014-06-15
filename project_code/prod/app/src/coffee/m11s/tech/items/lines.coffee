class mk.m11s.tech.TrailLine

  colors : []

  constructor : (@j1, @j2, @pct) ->
    @length = 40
    @path = new paper.Path()
    @path.add([0,0]) for i in [0...@length]
    @path.strokeWidth = 4
    @path.strokeCap = 'round'
    @path.strokeColor = mk.m11s.tech.TrailLine::colors.random()
    @prev = new paper.Point()
    @pos = new paper.Point()
    @bUpdate = 0
    @brightnessInterval()

  brightnessInterval : =>
    # @path.strokeColor.brightness = Math.random()
    @path.strokeColor = mk.m11s.tech.TrailLine::colors.random()
    delayed rng('t')*600+300, @brightnessInterval

  update : (dt) ->
    @pos.x = @j1.x * @pct + @j2.x * (1-@pct)
    @pos.y = @j1.y * @pct + @j2.y * (1-@pct)
    @pos.x = @prev.x + (@pos.x - @prev.x) * 0.005 * dt
    @pos.y = @prev.y + (@pos.y - @prev.y) * 0.005 * dt
    @path.add @pos
    @path.removeSegment(0)
    @prev.x = @pos.x
    @prev.y = @pos.y



class mk.m11s.tech.Line
  constructor : (@j1, @j2, @pct) ->
    @path = new paper.Path()
    @path.segments = [[0,0],[0,0]]
    @path.strokeWidth = 5
    @path.strokeCap = 'round'
    @path.strokeColor = 'red'
    @pos = new paper.Point(0,0)
    @dest = new paper.Point(0,0)
    @speed = 0.0001
    @setDest()
  update : (dt) ->
    @setDest()
    @pos.x += (@dest.x - @pos.x ) * @speed * dt
    @pos.y += (@dest.y - @pos.y ) * @speed * dt
    @path.segments[0].point.x = @dest.x
    @path.segments[0].point.y = @dest.y
    @path.segments[1].point.x = @pos.x
    @path.segments[1].point.y = @pos.y
    @path.strokeColor.brightness = Math.random()
  setDest : ->
    @dest.x = @j1.x * @pct + @j2.x * (1-@pct)
    @dest.y = @j1.y * @pct + @j2.y * (1-@pct)


class mk.m11s.tech.Trail
  constructor : (@parts, @head, @pelvis) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 9999

    # parts = @parts.slice(0)
    # parts.push
    #   joints : [@head.joints[0], @pelvis.joints[0]]

    for c in ['skin','cream','beige','red','lightRed']
      color = new paper.Color mk.Scene::settings.getHexColor(c)
      mk.m11s.tech.TrailLine::colors.push color

    @lines = []
    @numLinePerPart = 9
    for p in parts
      for i in [1...@numLinePerPart]
        # console.log p.joints[0]
        line = new mk.m11s.tech.TrailLine p.joints[0], p.joints[1], i * (1/@numLinePerPart)
        # line.path.strokeColor = @colors.seedRandom 'triblines'
        @lines.push line
        @view.addChild line.path

  update : (dt) ->
    for line in @lines
      line.update(dt)