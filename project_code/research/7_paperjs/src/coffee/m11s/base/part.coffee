class mk.m11s.base.Part
  
  constructor: (@name, @joints, @color, numPoints=4, addFirstJointView=true) ->
    @view = new paper.Group()
    @path = new paper.Path()
    @path.closed = true
    @path.add new paper.Point() while @path.segments.length < numPoints
    @view.addChild @path
    @jointViews = []
    if addFirstJointView
      @addJointView 0
    @z = 0
    @setColor @color

  setColor: (@color) ->
    @path.fillColor = "#" + @color.toString(16)

  update: () ->
    @updatePath()
    @updateZ()
    @updateJointViews()

  updatePath : () ->
    tangents = @getJointCircleTangents @joints[0], @joints[1]
    if !tangents or !tangents[0] or !tangents[1] then return
    @setSegmentPos 0, tangents[0][0], tangents[0][1]
    @setSegmentPos 1, tangents[1][0], tangents[1][1]
    @setSegmentPos 2, tangents[1][2], tangents[1][3]
    @setSegmentPos 3, tangents[0][2], tangents[0][3]

  updateZ : (forceToValue=null) ->
    if forceToValue is null
      @z = 0
      for i in [0...@joints.length]
        @z += @joints[i].z
      @z /= @joints.length
    else @z = forceToValue
    @view.z = @z

  updateJointViews : () ->
    jv.update() for jv in @jointViews

  addJointView: (jid) ->
    j = @joints[jid]
    jv = new mk.m11s.base.JointView j, @color
    @jointViews.push jv
    @view.addChild jv.view

  setSegmentPos: (i, x, y) ->
    @path.segments[i].point.x = x
    @path.segments[i].point.y = y

  getJointTangents: (px, py, jnt) ->
    cx = jnt.x
    cy =  jnt.y
    radius = jnt.radius
    return GeomUtils.getTangents(px, py, cx, cy, radius)

  getJointCircleTangents: (j1, j2) ->
    return GeomUtils.getCircleTangents j1.x, j1.y, j1.radius, j2.x, j2.y, j2.radius

# HEAD

class mk.m11s.base.Head extends mk.m11s.base.Part

  updatePath : ->
    return

# TORSO

class mk.m11s.base.Torso extends mk.m11s.base.Part

  constructor: (@name, @joints, @color, numJoints=7) ->
    super @name, @joints, @color, numJoints, false
    @addJointView 0
    @addJointView 1
    @addJointView 2

  updatePath: () ->
    head_jnt = @joints[3]
    head_to_right_shoulder  = @getJointTangents head_jnt.x, head_jnt.y, @joints[2]
    head_to_left_shoulder   = @getJointTangents head_jnt.x, head_jnt.y, @joints[1]
    right_shoulder_to_torso = @getJointCircleTangents @joints[2], @joints[0]
    left_shoulder_to_torso  = @getJointCircleTangents @joints[1], @joints[0]

    @setSegmentPos 0, head_jnt.x, head_jnt.y
    if head_to_right_shoulder
      @setSegmentPos 1, head_to_right_shoulder[0][0], head_to_right_shoulder[0][1]
    if right_shoulder_to_torso
      @setSegmentPos 2, right_shoulder_to_torso[1][0], right_shoulder_to_torso[1][1]
      @setSegmentPos 3, right_shoulder_to_torso[1][2], right_shoulder_to_torso[1][3]
    if left_shoulder_to_torso
      @setSegmentPos 4, left_shoulder_to_torso[0][2], left_shoulder_to_torso[0][3]
      @setSegmentPos 5, left_shoulder_to_torso[0][0], left_shoulder_to_torso[0][1]
    if head_to_left_shoulder
      @setSegmentPos 6, head_to_left_shoulder[1][0], head_to_left_shoulder[1][1]

# PELVIS

class mk.m11s.base.Pelvis extends mk.m11s.base.Part

  updatePath: () ->
    torso_to_righthip   = @getJointCircleTangents @joints[0], @joints[2]
    righthip_to_lefthip = @getJointCircleTangents @joints[2], @joints[1]
    lefthip_to_torso    = @getJointCircleTangents @joints[1], @joints[0]

    if torso_to_righthip
      @setSegmentPos 0, torso_to_righthip[1][0], torso_to_righthip[1][1]
      @setSegmentPos 1, torso_to_righthip[1][2], torso_to_righthip[1][3]
    if righthip_to_lefthip
      @setSegmentPos 2, righthip_to_lefthip[1][0], righthip_to_lefthip[1][1]
      @setSegmentPos 3, righthip_to_lefthip[1][2], righthip_to_lefthip[1][3]
    if lefthip_to_torso
      @setSegmentPos 4, lefthip_to_torso[1][0], lefthip_to_torso[1][1]
      @setSegmentPos 5, lefthip_to_torso[1][2], lefthip_to_torso[1][3]