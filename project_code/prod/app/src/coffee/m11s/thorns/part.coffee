# HEAD

class mk.m11s.thorns.Head extends mk.m11s.base.Head

  constructor: (@name, @joints, @color, numPoints=4, addFirstJointView=true) ->
    @view = new paper.Group()
    # @path = new paper.Path()
    # @path.closed = true
    # @path.add new paper.Point() while @path.segments.length < numPoints
    # @view.addChild @path
    @jointViews = []
    # if addFirstJointView
    #   @addJointView 0
    @z = 0
    # @setColor @color