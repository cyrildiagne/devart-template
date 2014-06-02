class mk.m11s.base.Joint
  constructor: (@type, @radius) ->
    @x = 0
    @y = 0
    @z = 0

class mk.m11s.base.JointView
  constructor: (@joint, @color="#ff0000") ->
    @view = new paper.Path.Circle
      center: [0, 0]
      radius: @joint.radius
    @setColor @color

  setColor : (@color) ->
    @view.fillColor = "#" + @color.toString(16)

  update : () ->
    @view.position.x = @joint.x
    @view.position.y = @joint.y