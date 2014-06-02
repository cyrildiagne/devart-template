class mk.m11s.base.Morph

  constructor: (@joints, @settings) ->
    #...

  update: () ->

    headP         = @getPos NiTE.HEAD
    leftShouldP   = @getPos NiTE.LEFT_SHOULDER
    rightShouldP  = @getPos NiTE.RIGHT_SHOULDER
    leftElbowP    = @getPos NiTE.LEFT_ELBOW
    rightElbowP   = @getPos NiTE.RIGHT_ELBOW
    leftHipP      = @getPos NiTE.LEFT_HIP
    rightHipP     = @getPos NiTE.RIGHT_HIP
    leftKneeP     = @getPos NiTE.LEFT_KNEE
    rightKneeP    = @getPos NiTE.RIGHT_KNEE
    leftFootP     = @getPos NiTE.LEFT_FOOT
    rightFootP    = @getPos NiTE.RIGHT_FOOT
    torsoP        = @getPos NiTE.TORSO

    s = @settings

    # bring shoulders closer to head level
    leftShouldP.y   += (headP.y-leftShouldP.y) * s.shouldersToHead
    leftShouldP.x   += (headP.x-leftShouldP.x) * s.shouldersToHead
    rightShouldP.y  += (headP.y-rightShouldP.y) * s.shouldersToHead
    rightShouldP.x  += (headP.x-rightShouldP.x) * s.shouldersToHead

    # push shoulders horizontally away
    leftShouldP.x   += (-rightShouldP.x+leftShouldP.x) * s.shouldersAppart
    rightShouldP.x  += (-leftShouldP.x+rightShouldP.x) * s.shouldersAppart

    # bring elbows closer to shoulders vertical level
    leftElbowP.y  += (rightShouldP.y-leftElbowP.y) * s.elbowsToShoulders
    rightElbowP.y += (leftShouldP.y-rightElbowP.y) * s.elbowsToShoulders

    # smaller pelvis by lowering torso
    torsoP.y += ((rightHipP.y+leftHipP.y)/2-torsoP.y) * s.torsoLow
    torsoP.x += ((rightHipP.x+leftHipP.x)/2-torsoP.x) * s.torsoLow

    # smaller pelvis by moving hips toward each other horizontally
    leftHipP.x  += (rightHipP.x-leftHipP.x) * s.hipsCloser
    rightHipP.x += (leftHipP.x-rightHipP.x) * s.hipsCloser

    # makes legs longer by lowering feet and knees
    leftFootP.y   += (-leftKneeP.y+leftFootP.y) * s.lowFeet
    rightFootP.y  += (-rightKneeP.y+leftFootP.y) * s.lowFeet

    # prevent left shoulder and right shoulder to cross
    if leftShouldP.x > rightShouldP.x
      leftShouldPx    = leftShouldP.x 
      leftShouldP.x   = rightShouldP.x
      rightShouldP.x  = leftShouldPx

  getPos: (joinType) ->
    return @joints[joinType]