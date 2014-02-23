class PersoJoint

  constructor : (@radius=0.005) ->

    @isDragged = false

    @view = new PIXI.Graphics()
    @view.interactive = true
    @view.mouseover = @onMouseOver
    @view.mouseout = @onMouseOut
    @view.mousedown = @onMouseDown
    @view.buttonMode = true

    @setRadius @radius

  setRadius : (@radius) ->
    @view.hitArea = new PIXI.Circle(0, 0, @radius)
    @draw()

  draw : (color = 0xff0000) ->
    @view.clear()
    @view.lineStyle(1, color)
    @view.drawCircle(0, 0, @radius)

  onMouseOver : () =>
    @view.alpha = 0.5
    @draw 0x00ffff

  onMouseOut : () =>
    @view.alpha = 1
    @draw 0xff0000

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

class Perso

  @radius = [
    0.020,  # HEAD
    0,      # NECK
    0.008,  # LEFT_SHOULDER
    0.008,  # RIGHT_SHOULDER
    0.003,  # LEFT_ELBOW
    0.003,  # RIGHT_ELBOW
    0.003,  # LEFT_HAND
    0.003,  # RIGHT_HAND
    0.025,  # TORSO
    0.012,  # LEFT_HIP
    0.012,  # RIGHT_HIP
    0.008,  # LEFT_KNEE
    0.008,  # RIGHT_KNEE
    0.003,  # LEFT_FOOT
    0.003,  # RIGHT_FOOT
  ]

  @morph =
    shouldersToHead : 0.6
    shouldersAppart : 0.05
    elbowsToShoulders : 0.25
    torsoLow : 0.3
    hipsCloser : 0.25
    lowFeet : 0.2

  constructor: () ->
    @view = new PIXI.DisplayObjectContainer()
    @joints = []
    for i in [0...NiTE.NUM_JOINTS]
      jnt = new PersoJoint()
      jnt.draggedCallback = =>
        @update()
      if i isnt NiTE.NECK
        @view.addChild jnt.view
      @joints.push jnt

    @gfx = new PIXI.Graphics()
    @view.addChild @gfx

  setFromSkeleton: (skeleton) ->
    for i in [0...skeleton.joints.length]
      @joints[i].view.position.x = skeleton.joints[i].view.position.x
      @joints[i].view.position.y = skeleton.joints[i].view.position.y
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

    # bring shoulders closer to head vertical level
    leftShouldP.y += (headP.y-leftShouldP.y) * Perso.morph.shouldersToHead
    rightShouldP.y += (headP.y-rightShouldP.y) * Perso.morph.shouldersToHead

    # push shoulders horizontally away
    leftShouldP.x += (-rightShouldP.x+leftShouldP.x) * Perso.morph.shouldersAppart
    rightShouldP.x += (-leftShouldP.x+rightShouldP.x) * Perso.morph.shouldersAppart

    # bring elbows closer to shoulders vertical level
    leftElbowP.y += (rightShouldP.y-leftElbowP.y) * Perso.morph.elbowsToShoulders
    rightElbowP.y += (leftShouldP.y-rightElbowP.y) * Perso.morph.elbowsToShoulders

    # smaller pelvis by lowering torso
    torsoP.y += ((rightHipP.y+leftHipP.y)/2-torsoP.y) * Perso.morph.torsoLow

    # smaller pelvis by moving hips toward each other horizontally
    leftHipP.x += (rightHipP.x-leftHipP.x) * Perso.morph.hipsCloser
    rightHipP.x += (leftHipP.x-rightHipP.x) * Perso.morph.hipsCloser

    # makes legs longer by lowering feet
    leftFootP.y += (-leftKneeP.y+leftFootP.y) * Perso.morph.lowFeet
    rightFootP.y += (-rightKneeP.y+leftFootP.y) * Perso.morph.lowFeet

  getPos: (joinType) ->
    return @joints[joinType].view.position

  update: () ->
    @gfx.clear()
    @gfx.lineStyle(1, 0x000000, 0.3)

    # place neck joint automatically
    np = @getPos NiTE.NECK
    rsp = @getPos NiTE.LEFT_SHOULDER
    lsp = @getPos NiTE.RIGHT_SHOULDER
    np.x = (lsp.x + rsp.x) / 2
    np.y = (lsp.y + rsp.y) / 2
    
    for bone in NiTE.bones
      j1p = @getPos bone[0]
      j2p = @getPos bone[1]
      @gfx.moveTo j1p.x, j1p.y
      @gfx.lineTo j2p.x, j2p.y

    @gfx.lineStyle 1, 0x000000, 1

    # draw torso
    @drawCircleTangents NiTE.LEFT_SHOULDER, NiTE.TORSO, [0]
    @drawCircleTangents NiTE.RIGHT_SHOULDER, NiTE.TORSO, [1]
    @drawTangent NiTE.HEAD, NiTE.LEFT_SHOULDER, [1]
    @drawTangent NiTE.HEAD, NiTE.RIGHT_SHOULDER, [0]

    # draw pelvis
    @drawCircleTangents NiTE.LEFT_HIP, NiTE.TORSO, [1]
    @drawCircleTangents NiTE.RIGHT_HIP, NiTE.TORSO, [0]
    @drawCircleTangents NiTE.RIGHT_HIP, NiTE.LEFT_HIP, [1]

    # draw left arm
    @drawCircleTangents NiTE.LEFT_SHOULDER, NiTE.LEFT_ELBOW
    @drawCircleTangents NiTE.LEFT_ELBOW, NiTE.LEFT_HAND

    # draw right arm
    @drawCircleTangents NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW
    @drawCircleTangents NiTE.RIGHT_ELBOW, NiTE.RIGHT_HAND

    # draw left leg
    @drawCircleTangents NiTE.LEFT_HIP, NiTE.LEFT_KNEE
    @drawCircleTangents NiTE.LEFT_KNEE, NiTE.LEFT_FOOT

    # draw right leg
    @drawCircleTangents NiTE.RIGHT_HIP, NiTE.RIGHT_KNEE
    @drawCircleTangents NiTE.RIGHT_KNEE, NiTE.RIGHT_FOOT

  drawTangent: (j1_type, j2_type, indexes=[0,1]) ->
    px = @getPos(j1_type).x
    py = @getPos(j1_type).y
    j = @joints[j2_type]
    jp = j.view.position
    tangents = @getTangent px, py, jp.x, jp.y, j.radius
    
    if tangents
      for i in indexes
        tgt = tangents[i]
        @gfx.moveTo px, py
        @gfx.lineTo tgt[0], tgt[1]

  getTangent: (px, py, cx, cy, radius) ->
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

  drawCircleTangents: (j1_type, j2_type, indexes=[0, 1]) ->
    j1 = @joints[j1_type]
    j1p = j1.view.position
    j2 = @joints[j2_type]
    j2p = j2.view.position
    tangents = @getCircleTangents j1p.x, j1p.y, j1.radius, j2p.x, j2p.y, j2.radius
    if tangents
      for i in indexes
        tgt = tangents[i]
        @gfx.moveTo tgt[0], tgt[1]
        @gfx.lineTo tgt[2], tgt[3]

  # ported from http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Tangents_between_two_circles
  getCircleTangents: (x1, y1, r1, x2, y2, r2) ->
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