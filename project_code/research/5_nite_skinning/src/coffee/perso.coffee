class PersoJoint

  constructor : (@interactive=true) ->

    @isDragged = false
    @bDebug = false
    @z = 0
    @view = new PIXI.Graphics()
    if @interactive
      @view.interactive = true
      @view.mouseover = @onMouseOver
      @view.mouseout = @onMouseOut
      @view.mousedown = @onMouseDown
      @view.buttonMode = true
      @setRadius @radius

  setRadius : (@radius) ->
    @view.hitArea = new PIXI.Circle(0, 0, @radius)
    @draw()

  setDebug : (@bDebug) ->
    @draw()

  draw : (highlight = false) ->
    @view.clear()
    if highlight
      @view.beginFill(0x00ffff)
    else
      if @bDebug
        @view.lineStyle(1, 0x000000)
    @view.drawCircle(0, 0, @radius)

  onMouseOver : () =>
    @view.alpha = 0.5
    @draw true

  onMouseOut : () =>
    @view.alpha = 1
    @draw()

  onMouseDown : () =>
    @isDragged = true
    stage.mouseup = @onMouseUp
    stage.mousemove = @onDrag

  onDrag : (ev) =>
    @view.position.x = ev.originalEvent.clientX - @view.parent.position.x
    @view.position.y = ev.originalEvent.clientY - @view.parent.position.y
    if @draggedCallback
      @draggedCallback()

  onMouseUp : () =>
    @isDragged = false
    stage.mouseup = null
    stage.mousemove = null


class PersoPart

  constructor: (@name, @color, @joints, @drawFunc) ->
    @z = 0
    @update()

  update: () ->
    @z = 0
    for i in [0...@joints.length]
      @z += @joints[i].z
    @z /= @joints.length
    

class Perso

  @radius = [
    0.020, # HEAD
    0,     # NECK
    0.008, # LEFT_SHOULDER
    0.008, # RIGHT_SHOULDER
    0.003, # LEFT_ELBOW
    0.003, # RIGHT_ELBOW
    0.003, # LEFT_HAND
    0.003, # RIGHT_HAND
    0.020, # TORSO
    0.012, # LEFT_HIP
    0.012, # RIGHT_HIP
    0.008, # LEFT_KNEE
    0.008, # RIGHT_KNEE
    0.003, # LEFT_FOOT
    0.003, # RIGHT_FOOT
  ]

  @palette =
    skin : 0xdec6c2
    cream : 0xe4e6dd
    lightblue : 0x97c6c9
    blue : 0x629498
    beige : 0xcac8ad
    lightGreen : 0xb5cec0

  @morph =
    shouldersToHead : 0.6
    shouldersAppart : 0.6
    elbowsToShoulders : 0.25
    torsoLow : 0.3
    hipsCloser : 0.25
    lowFeet : 0.2

  constructor: (@interactive) ->

    @view = new PIXI.DisplayObjectContainer()
    @joints = []
    for i in [0...NiTE.NUM_JOINTS]
      jnt = new PersoJoint @interactive
      jnt.draggedCallback = =>
        @update()
      if i isnt NiTE.NECK
        @view.addChild jnt.view
      @joints.push jnt

    @gfx = new PIXI.Graphics()
    @view.addChildAt @gfx,0
    @bDebug = false

    @parts = null
    @setupParts()
      

  setupParts: () ->

    P = Perso.palette
    colors =
      head:          P.skin
      torso:         P.cream
      pelvis:        P.lightblue
      leftUpperArm:  P.beige
      leftLowerArm:  P.beige
      rightUpperArm: P.lightGreen
      rightLowerArm: P.lightGreen
      leftUpperLeg:  P.lightblue
      leftLowerLeg:  P.blue
      rightUpperLeg: P.lightblue
      rightLowerLeg: P.blue

    partsDefs =
      leftUpperArm:  [NiTE.LEFT_SHOULDER,  NiTE.LEFT_ELBOW]
      leftLowerArm:  [NiTE.LEFT_ELBOW,     NiTE.LEFT_HAND]
      leftUpperLeg:  [NiTE.LEFT_HIP,       NiTE.LEFT_KNEE]
      leftLowerLeg:  [NiTE.LEFT_KNEE,      NiTE.LEFT_FOOT]
      rightUpperArm: [NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW]
      rightLowerArm: [NiTE.RIGHT_ELBOW,    NiTE.RIGHT_HAND]
      rightUpperLeg: [NiTE.RIGHT_HIP,      NiTE.RIGHT_KNEE]
      rightLowerLeg: [NiTE.RIGHT_KNEE,     NiTE.RIGHT_FOOT]
      pelvis:        [NiTE.TORSO,          NiTE.LEFT_HIP,       NiTE.RIGHT_HIP]
      torso:         [NiTE.TORSO,          NiTE.LEFT_SHOULDER,  NiTE.RIGHT_SHOULDER]
      head:          [NiTE.HEAD]
    @parts = []

    for p, parts of partsDefs
      capitalized = p[0].toUpperCase() + p[1..-1]
      part = new PersoPart p, colors[p], @getJoints(parts), @['draw'+capitalized]
      @parts.push part


  getJoints: (types) ->
    res = []
    for type in types
      res.push @joints[type]
    return res

  setFromSkeleton: (skeleton) ->
    for i in [0...skeleton.joints.length]
      @joints[i].view.position.x = skeleton.joints[i].view.position.x
      @joints[i].view.position.y = skeleton.joints[i].view.position.y
      @joints[i].z = skeleton.joints[i].z
      @joints[i].setRadius Perso.radius[i]*skeleton.width*2
    @morphSkeleton()

  morphSkeleton: () ->
    headP = @getPos NiTE.HEAD
    leftShouldP = @getPos NiTE.LEFT_SHOULDER
    rightShouldP = @getPos NiTE.RIGHT_SHOULDER
    leftElbowP = @getPos NiTE.LEFT_ELBOW
    rightElbowP = @getPos NiTE.RIGHT_ELBOW
    leftHipP = @getPos NiTE.LEFT_HIP
    rightHipP = @getPos NiTE.RIGHT_HIP
    leftKneeP = @getPos NiTE.LEFT_KNEE
    rightKneeP = @getPos NiTE.RIGHT_KNEE
    leftFootP = @getPos NiTE.LEFT_FOOT
    rightFootP = @getPos NiTE.RIGHT_FOOT
    torsoP = @getPos NiTE.TORSO

    # bring shoulders closer to head level
    leftShouldP.y += (headP.y-leftShouldP.y) * Perso.morph.shouldersToHead
    leftShouldP.x += (headP.x-leftShouldP.x) * Perso.morph.shouldersToHead
    rightShouldP.y += (headP.y-rightShouldP.y) * Perso.morph.shouldersToHead
    rightShouldP.x += (headP.x-rightShouldP.x) * Perso.morph.shouldersToHead

    # push shoulders horizontally away
    leftShouldP.x += (-rightShouldP.x+leftShouldP.x) * Perso.morph.shouldersAppart
    rightShouldP.x += (-leftShouldP.x+rightShouldP.x) * Perso.morph.shouldersAppart

    # bring elbows closer to shoulders vertical level
    leftElbowP.y += (rightShouldP.y-leftElbowP.y) * Perso.morph.elbowsToShoulders
    rightElbowP.y += (leftShouldP.y-rightElbowP.y) * Perso.morph.elbowsToShoulders

    # smaller pelvis by lowering torso
    torsoP.y += ((rightHipP.y+leftHipP.y)/2-torsoP.y) * Perso.morph.torsoLow
    torsoP.x += ((rightHipP.x+leftHipP.x)/2-torsoP.x) * Perso.morph.torsoLow

    # smaller pelvis by moving hips toward each other horizontally
    leftHipP.x += (rightHipP.x-leftHipP.x) * Perso.morph.hipsCloser
    rightHipP.x += (leftHipP.x-rightHipP.x) * Perso.morph.hipsCloser

    # makes legs longer by lowering feet and knees
    leftFootP.y += (-leftKneeP.y+leftFootP.y) * Perso.morph.lowFeet
    rightFootP.y += (-rightKneeP.y+leftFootP.y) * Perso.morph.lowFeet

    # prevent left shoulder and right shoulder to cross
    if leftShouldP.x > rightShouldP.x
      leftShouldPx = leftShouldP.x 
      leftShouldP.x = rightShouldP.x
      rightShouldP.x = leftShouldPx

  getPos: (joinType) ->
    return @joints[joinType].view.position

  getPart: (name) ->
    for part in @parts
      if part.name == name then return part
    
  update: () ->
    
    # place neck joint automatically if not using NiTE backend
    if typeof sync is 'undefined'
      np = @getPos NiTE.NECK
      rsp = @getPos NiTE.LEFT_SHOULDER
      lsp = @getPos NiTE.RIGHT_SHOULDER
      np.x = (lsp.x + rsp.x) / 2
      np.y = (lsp.y + rsp.y) / 2

    @gfx.clear()
    if @bDebug
      @drawBones()

    #reorder parts
    for part in @parts
      part.update()
    @getPart('head').z = @getPart('torso').z+2 # head always 'just' on top of body
    @getPart('pelvis').z = @getPart('torso').z+1 # pelvis always 'just' on top of body
    @parts.sort (a, b) ->
      return if a.z > b.z then 1 else -1
    
    @drawBody()
  
  setDebug: (@bDebug) ->
    for j in @joints
      j.setDebug @bDebug

  drawBones: () ->
    @gfx.lineStyle(1, 0x000000, 0.3)
    for bone in NiTE.bones
      j1p = @getPos bone[0]
      j2p = @getPos bone[1]
      @gfx.moveTo j1p.x, j1p.y
      @gfx.lineTo j2p.x, j2p.y

  drawBody: () ->
    if @bDebug
      @gfx.lineStyle 1, 0x000000, 1
    else
      @gfx.lineStyle 0
    for i in [0...@parts.length]
      p = @parts[i]
      p.drawFunc p
    return

  drawHead: (part) =>
    hp = @getPos NiTE.HEAD
    if !@bDebug
      @gfx.beginFill part.color
    @gfx.drawCircle hp.x, hp.y, @joints[NiTE.HEAD].radius
    @gfx.endFill()

  drawTorso: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_SHOULDER, NiTE.TORSO, [0]
      @drawCircleTangentsDebug NiTE.RIGHT_SHOULDER, NiTE.TORSO, [1]
      @drawTangentDebug NiTE.HEAD, NiTE.LEFT_SHOULDER, [1]
      @drawTangentDebug NiTE.HEAD, NiTE.RIGHT_SHOULDER, [0]
    else
      hp = @getPos NiTE.HEAD
      tp = @getPos NiTE.TORSO
      @gfx.beginFill part.color
      @drawJoint NiTE.TORSO
      @drawJoint NiTE.LEFT_SHOULDER
      @drawJoint NiTE.RIGHT_SHOULDER
      head_to_right_shoulder  = @getJointTangents hp.x, hp.y, NiTE.RIGHT_SHOULDER
      head_to_left_shoulder   = @getJointTangents hp.x, hp.y, NiTE.LEFT_SHOULDER
      right_shoulder_to_torso = @getJointCircleTangents NiTE.RIGHT_SHOULDER, NiTE.TORSO
      left_shoulder_to_torso  = @getJointCircleTangents NiTE.LEFT_SHOULDER, NiTE.TORSO
      @gfx.moveTo hp.x, hp.y
      if head_to_right_shoulder
        @gfx.lineTo head_to_right_shoulder[0][0], head_to_right_shoulder[0][1]
      if right_shoulder_to_torso
        @gfx.lineTo right_shoulder_to_torso[1][0], right_shoulder_to_torso[1][1]
        @gfx.lineTo right_shoulder_to_torso[1][2], right_shoulder_to_torso[1][3]
      if left_shoulder_to_torso
        @gfx.lineTo left_shoulder_to_torso[0][2], left_shoulder_to_torso[0][3]
        @gfx.lineTo left_shoulder_to_torso[0][0], left_shoulder_to_torso[0][1]
      if head_to_left_shoulder
        @gfx.lineTo head_to_left_shoulder[1][0], head_to_left_shoulder[1][1]
      @gfx.lineTo hp.x, hp.y
      @gfx.endFill()

  drawPelvis: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_HIP, NiTE.TORSO, [1]
      @drawCircleTangentsDebug NiTE.RIGHT_HIP, NiTE.TORSO, [0]
      @drawCircleTangentsDebug NiTE.RIGHT_HIP, NiTE.LEFT_HIP, [1]
    else
      @gfx.beginFill part.color
      torso_to_righthip = @getJointCircleTangents NiTE.TORSO, NiTE.RIGHT_HIP
      righthip_to_lefthip = @getJointCircleTangents NiTE.RIGHT_HIP, NiTE.LEFT_HIP
      lefthip_to_torso = @getJointCircleTangents NiTE.LEFT_HIP, NiTE.TORSO
      if !torso_to_righthip then return
      @gfx.moveTo torso_to_righthip[1][0], torso_to_righthip[1][1]
      @gfx.lineTo torso_to_righthip[1][2], torso_to_righthip[1][3]
      if righthip_to_lefthip
        @gfx.lineTo righthip_to_lefthip[1][0], righthip_to_lefthip[1][1]
        @gfx.lineTo righthip_to_lefthip[1][2], righthip_to_lefthip[1][3]
      if lefthip_to_torso
        @gfx.lineTo lefthip_to_torso[1][0], lefthip_to_torso[1][1]
        @gfx.lineTo lefthip_to_torso[1][2], lefthip_to_torso[1][3]
      @gfx.endFill()

  drawLeftUpperLeg: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_HIP, NiTE.LEFT_KNEE
    else
      @gfx.beginFill part.color
      @drawJoint NiTE.LEFT_HIP
      lefthip_to_leftknee = @getJointCircleTangents NiTE.LEFT_HIP, NiTE.LEFT_KNEE
      @drawTangetsQuad lefthip_to_leftknee
      @gfx.endFill()

  drawLeftLowerLeg: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_KNEE, NiTE.LEFT_FOOT
    else
      @gfx.beginFill part.color
      leftknee_to_leftfoot = @getJointCircleTangents NiTE.LEFT_KNEE, NiTE.LEFT_FOOT
      @drawTangetsQuad leftknee_to_leftfoot
      @drawJoint NiTE.LEFT_KNEE
      @gfx.endFill()
      
  drawRightUpperLeg: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.RIGHT_HIP, NiTE.RIGHT_KNEE
    else
      @gfx.beginFill part.color
      @drawJoint NiTE.RIGHT_HIP
      righthip_to_rightknee = @getJointCircleTangents NiTE.RIGHT_HIP, NiTE.RIGHT_KNEE
      @drawTangetsQuad righthip_to_rightknee
      @gfx.endFill

  drawRightLowerLeg: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.RIGHT_KNEE, NiTE.RIGHT_FOOT
    else
      @gfx.beginFill part.color
      rightknee_to_rightfoot = @getJointCircleTangents NiTE.RIGHT_KNEE, NiTE.RIGHT_FOOT
      @drawTangetsQuad rightknee_to_rightfoot
      @drawJoint NiTE.RIGHT_KNEE
      @gfx.endFill()

  drawLeftUpperArm: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_SHOULDER, NiTE.LEFT_ELBOW
    else
      @gfx.beginFill part.color
      @drawJoint NiTE.LEFT_SHOULDER
      leftarm_to_leftelbow = @getJointCircleTangents NiTE.LEFT_SHOULDER, NiTE.LEFT_ELBOW
      @drawTangetsQuad leftarm_to_leftelbow
      @gfx.endFill()

  drawLeftLowerArm: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.LEFT_ELBOW, NiTE.LEFT_HAND
    else
      @gfx.beginFill part.color
      leftelbow_to_lefthand = @getJointCircleTangents NiTE.LEFT_ELBOW, NiTE.LEFT_HAND
      @drawTangetsQuad leftelbow_to_lefthand
      @drawJoint NiTE.LEFT_ELBOW
      @gfx.endFill()

  drawRightUpperArm: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW
    else
      @gfx.beginFill part.color
      @drawJoint NiTE.RIGHT_SHOULDER
      rightarm_to_rightelbow = @getJointCircleTangents NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW
      @drawTangetsQuad rightarm_to_rightelbow
      @gfx.endFill()

  drawRightLowerArm: (part) =>
    if @bDebug
      @drawCircleTangentsDebug NiTE.RIGHT_ELBOW, NiTE.RIGHT_HAND
    else
      @gfx.beginFill part.color
      rightelbow_to_righthand = @getJointCircleTangents NiTE.RIGHT_ELBOW, NiTE.RIGHT_HAND
      @drawTangetsQuad rightelbow_to_righthand
      @drawJoint NiTE.RIGHT_ELBOW
      @gfx.endFill()


  # utils

  drawJoint: (joint_type) ->
      p = @getPos joint_type
      # @gfx.beginFill color
      @gfx.drawCircle p.x, p.y, @joints[joint_type].radius
      # @gfx.endFill()

  drawTangetsQuad: (tangents) ->
    if !tangents or !tangents[0] or !tangents[1] then return
    # @gfx.beginFill color
    @gfx.moveTo tangents[0][0], tangents[0][1]
    @gfx.lineTo tangents[1][0], tangents[1][1]
    @gfx.lineTo tangents[1][2], tangents[1][3]
    @gfx.lineTo tangents[0][2], tangents[0][3]
    # @gfx.endFill()

  drawTangentDebug: (j1_type, j2_type, indexes=[0,1]) ->
    px = @getPos(j1_type).x
    py = @getPos(j1_type).y
    tangents = @getJointTangents px, py, j2_type
    if tangents
      for i in indexes
        tgt = tangents[i]
        @gfx.moveTo px, py
        @gfx.lineTo tgt[0], tgt[1]

  drawCircleTangentsDebug: (j1_type, j2_type, indexes=[0, 1]) ->
    tangents = @getJointCircleTangents j1_type, j2_type
    if tangents
      for i in indexes
        tgt = tangents[i]
        @gfx.moveTo tgt[0], tgt[1]
        @gfx.lineTo tgt[2], tgt[3]

  getJointTangents: (px, py, joint_type) ->
    jnt = @joints[joint_type]
    cx = jnt.view.position.x
    cy =  jnt.view.position.y
    radius = jnt.radius
    return @getTangents(px, py, cx, cy, radius)

  getJointCircleTangents: (j1_type, j2_type) ->
    j1 = @joints[j1_type]
    j1p = j1.view.position
    j2 = @joints[j2_type]
    j2p = j2.view.position
    return @getCircleTangents j1p.x, j1p.y, j1.radius, j2p.x, j2p.y, j2.radius

  getTangents: (px, py, cx, cy, radius) ->
    dx = cx - px
    dy = cy - py
    dd = Math.sqrt(dx * dx + dy * dy)
    a = Math.asin(radius / dd)
    b = Math.atan2(dy, dx)
    t = []
    t[0] = [
      cx + radius * Math.sin(b-a),
      cy + radius * -Math.cos(b-a)
    ]
    t[1] = [
      cx + radius * -Math.sin(b+a),
      cy + radius * Math.cos(b+a)
    ]
    return t

  getCircleTangents: (x1, y1, r1, x2, y2, r2) ->
    # ported from http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Tangents_between_two_circles
    d_sq = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
    if (d_sq <= (r1-r2)*(r1-r2)) 
      return null
    d = Math.sqrt(d_sq)
    vx = (x2 - x1) / d
    vy = (y2 - y1) / d
    res = [
      [0,0,0,0]
      [0,0,0,0]
      [0,0,0,0]
      [0,0,0,0]
    ]
    i = 0
    for  sign1 in [1..-1] by -2
        c = (r1 - sign1 * r2) / d
        if (c*c > 1.0) then continue
        h = Math.sqrt(Math.max(0.0, 1.0 - c*c))
        for sign2 in [1..-1] by -2
          nx = vx * c - sign2 * h * vy
          ny = vy * c + sign2 * h * vx
          a = res[i++]
          a[0] = x1 + r1 * nx
          a[1] = y1 + r1 * ny
          a[2] = x2 + sign1 * r2 * nx
          a[3] = y2 + sign1 * r2 * ny
    return res