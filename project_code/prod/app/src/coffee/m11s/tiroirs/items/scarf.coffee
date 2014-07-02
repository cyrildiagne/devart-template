class mk.m11s.tiroirs.ScarfPart extends mk.helpers.SimpleJointItem

  constructor: (@pinPoint, @options) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0, 0
    @view.z = 0

    @numPoints = 10
    @gravity   = 40
    @stiffness = 0.8
    @length    = 25
    @width     = 44
    @color     = '#97C6C9'
    @offset    = new paper.Point()

    @[k] = v for k,v of @options

    @path = null
    @end = null
    @setup()

  setup: ->
    @path = new paper.Path
      strokeColor : @color
      strokeWidth : @width
    @path.transformContent = false
    @view.addChild @path

    @end = new paper.Path
      strokeColor : @color
      strokeWidth : 30
      dashArray   : [4,4]
    @end.add [0, 0]
    @end.add [@width, 0]
    @end.transformContent = false
    @view.addChild @end

    for i in [0...@numPoints]
      @path.add new paper.Point(0, 0)
    
  update: ->

    @path.firstSegment.point = @offset.add [@pinPoint.x, @pinPoint.y]

    for i in [0...@numPoints-1]
    
      segment = @path.segments[i]
      nextSegment = segment.next
      vector = segment.point.subtract nextSegment.point
      vector.length = @length
      nextSegment.point.y += @gravity
      d = segment.point.subtract vector
      d = d.subtract nextSegment.point
      d = d.multiply @stiffness
      nextSegment.point = nextSegment.point.add d
    
    @path.smooth()
    
    s = @path.segments
    lastA = @path.segments[@numPoints-1].point
    lastB = @path.segments[@numPoints-2].point
    @end.position = lastA
    @end.rotation = lastA.subtract(lastB).angle - 90


class mk.m11s.tiroirs.Scarf extends mk.helpers.Flying

  constructor : ->

    @view = new paper.Group()
    @view.z = 9999

    @scarf1 = new mk.m11s.tiroirs.ScarfPart new paper.Point(),
      color     : mk.Scene::settings.getHexColor 'red'
      stiffness : 0.85
    @scarf1.view.z = 1997
    @view.addChild @scarf1.view

    # j = @joints[NiTE.LEFT_HAND]
    @scarf2 = new mk.m11s.tiroirs.ScarfPart new paper.Point(),
      color     : mk.Scene::settings.getHexColor ['cream','beige'].seedRandom('scarf')
      stiffness : 0.9
      numPoints : 6
    @scarf2.view.z = 1999
    @view.addChild @scarf2.view

  update : (p) ->
    @scarf1.pinPoint.x = @scarf2.pinPoint.x = p.x
    @scarf1.pinPoint.y = @scarf2.pinPoint.y = p.y - 10
    @scarf1.update()
    @scarf2.update()

  clean : ->
    @scarf1.view.remove()
    @scarf2.view.remove()