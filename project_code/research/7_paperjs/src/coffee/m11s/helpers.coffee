class mk.m11s.JointFollower

  constructor : (@view, @joint) ->
    @view.z = 0
    @zOffset = Math.random() + 50

  update : () ->
    @view.position.x = @joint.x
    @view.position.y = @joint.y
    @view.z = @joint.z + @zOffset

class mk.m11s.PartFillFollower

  constructor : (@view, @part, @weights) ->
    @view.z = 0
    @zOffset = Math.random() * 100 + 200
    @joints = @part.joints
    if @joints.length > 3
      @joints = @joints.slice(0, 3)

  update : () ->
    x = 0
    y = 0
    for j,i in @joints
      x += j.x * @weights[i]
      y += j.y * @weights[i]
    
    @view.position.x = x
    @view.position.y = y
    @view.z = @part.z + @zOffset