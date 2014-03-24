class mk.m11s.JointFollower
  constructor : (@view, @joint) ->
    @view.z = 0
    @zOffset = Math.random() + 50
  update : ->
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
  update : ->
    x = 0
    y = 0
    for j,i in @joints
      x += j.x * @weights[i]
      y += j.y * @weights[i]
    @view.position.x = x
    @view.position.y = y
    @view.z = @part.z + @zOffset


class mk.m11s.PartEdgeFollower
  constructor : (@view, @j1, @j2, @pct) ->
    @zOffset = Math.random() * 100 + 200
  update : ->
    x = @j1.x * @pct + @j2.x * (1-@pct)
    y = @j1.y * @pct + @j2.y * (1-@pct)
    @view.position.x = x
    @view.position.y = y
    @view.z = @j1.z * @pct + @j2.x * (1-@pct) + @zOffset


class mk.m11s.SimpleJointItem
  constructor : (@symbol, @joint) ->
    @view = @symbol.place()
    @view.z = 0
    @follower = new mk.m11s.JointFollower @view, @joint
  update: ->
    @follower.update()


class mk.m11s.SimplePartItem
  constructor: (@symbol, @part) ->
    @view = @symbol.place()
    @view.z = 0
    weights = mk.m11s.getRandomWeights @part.joints
    @follower = new mk.m11s.PartFillFollower @view, @part, weights
  update: ->
    @follower.update()


class mk.m11s.JointVelocityTracker
  constructor : (@jnts) ->
    @velocities = []
    @prev = []
    for j in @jnts
      @velocities.push 0
      p = new paper.Point(0, 0)
      @prev.push p
  update: ->
    for j,i in @jnts
      p = @prev[i]
      dx = j.x - p.x
      dy = j.y - p.y
      @velocities[i] = (dx*dx + dy*dy)
      p.x = j.x
      p.y = j.y
    return
  get: (i) ->
    return @velocities[i]


mk.m11s.getRandomWeights = (joints) ->
  weights = []
  sum = 0
  for j,i in joints
    if i < 3
      w = Math.random()
      weights.push w
      sum += w
  weights[i] /= sum for w,i in weights
  return weights