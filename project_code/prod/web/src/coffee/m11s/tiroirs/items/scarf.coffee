class mk.m11s.tiroirs.Scarf extends mk.m11s.SimpleJointItem

  constructor: (@joint, @options) ->
    @view = new paper.Group()
    @view.transformContent = false
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

    @path.firstSegment.point = @offset.add [@joint.x, @joint.y]

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