class mk.m11s.birds.Branches

  constructor: (@j1, @j2, @pct, options) ->
    @branchColor                = "#B5CEC0"
    @branchWidth                = 3
    @maxBranchWidth             = 10
    @maxBranches                = 7
    @minBranchLength            = 50
    @maxBranchLength            = 500
    @growSpeed                  = 0.025
    @timeBetweenBranches        = 675 * 8 * 0.65
    @minDistanceBetweenBranches = 8
    @firstBranchAngles          = [-135, -45]
    @shrinkSpeed                = 18
    @velMinForShrink            = 250

    @[k] = v for k, v of options

    @view = new paper.Group()
    @view.z = 0
    @view.transformContent = false
    @view.pivot = new paper.Point(0, 0)

    @bShrink = false
    @shrinkVel = 0
    @velTracker = new mk.helpers.JointVelocityTracker [@j1, @j2]

    @follower = new mk.helpers.PartEdgeFollower @view, @j1, @j2, @pct
    @branches = []
    @trackPoints = []
    @interval = 0
    @addBranch()

    @velocity = 0
    @prevX = @j1.x
    @prevY = @j1.y

  update: (dt) ->
    @interval+=dt
    if @interval >= @timeBetweenBranches
      @interval -= @timeBetweenBranches
      @newBranchTick()

    @view.z = @j2.z * @pct + @j1.z * (1-@pct)

    @follower.update()

    @velTracker.update()
    vel = @velTracker.get(0) + @velTracker.get(1)
    if vel < @shrinkVel
      @shrinkVel += (vel-@shrinkVel) * 0.02
    else @shrinkVel = vel
    @bShrink = @shrinkVel > @velMinForShrink

    d = (@j1.x - @prevX)*2 + (@j1.y - @prevY)*2
    speed = if @velocity > d then 0.02 else 0.04
    @velocity += (d - @velocity) * speed
    @prevX = @j1.x
    @prevY = @j1.y

    for b,i in @branches
      if b.parent
        b.currStart = b.parent.currStart.add b.parent.currVec.normalize(b.startLength)
      else
        b.currStart = b.start.clone()

      if @bShrink
        bAllChildrenShrunk = true
        for c in b.children
          if c.vec.length > 1 then bAllChildrenShrunk = false
        if bAllChildrenShrunk
          b.vec.length += (0-b.vec.length) * @growSpeed * @shrinkSpeed
        if b.vec.length < 3
          b.path.visible = false
        for it in b.items
          it.scale += (0-it.scale) * 0.2
          if it.view and it.scale > 0.01
            it.view.scaling = it.scale
            it.view.visible = false if it.view.visible and it.scale < 0.1
      else
        if !b.parent || b.parent.vec.length > b.startLength
          b.vec.length += (b.maxLength-b.vec.length) * @growSpeed
          if b.vec.length > 3 and !b.path.visible
            b.path.visible = true
            mk.Scene::sfx.play 'branch2'
        for it in b.items
          # console.log b.vec.length + ' ' + it.startLength
          if b.vec.length > it.startLength
            # console.log b.vec.length + ' ' + it.startLength
            it.scale += (1-it.scale) * 0.2
            if it.view
              it.view.scaling = it.scale
              it.view.visible = true if !it.view.visible

      b.currVec = b.vec.clone()
      b.currVec.angle = b.angle - @velocity * (i*1.5+1)

      b.path.segments[0].point = b.currStart
      b.path.segments[1].point = b.currStart.add b.currVec

    for tp,i in @trackPoints
      p = tp.parent.currStart.add tp.parent.currVec.normalize( tp.startLength )
      tp.pos.x = p.x
      tp.pos.y = p.y
      if tp.view
        tp.view.position = p
    return

  hasFreeSpace: (start, a) ->
    for b in @branches
      bCloseSeed = b.start.getDistance(start) < @minDistanceBetweenBranches
      sameAngle = Math.abs(a-b.vec.angle) < 1
      if bCloseSeed && sameAngle
        return false
    return true

  getValidAngle: (parentAngle) ->
    tries = 0
    a = 0
    loop
      rdmSign = Math.floor(rng('getValidAngle')*2+1)*2-3
      a = 30 * rdmSign - 90
      break if ++tries > 10 || Math.abs(a-parentAngle) > 1
    return a

  getValidStart: (parent, a) ->
    tries = 0
    startVec = new paper.Point()
    startVec.angle = parent.vec.angle
    loop
      # startVec.length = parent.vec.length * (rng('getValidStart')*0.5+0.5)
      startVec.length = parent.maxLength * (rng('getValidStart')*0.5+0.5)
      start = parent.start.add(startVec)
      break if ++tries > 10 || @hasFreeSpace(start, a)
    return startVec

  addBranch: () ->
    # mk.Scene::sfx.play 'branch1'

    a = 0
    start = null
    startVec = new paper.Point()
    parent = null

    if @branches.length
      parent   = @branches.seedRandom('addBranch1')
      a        = @getValidAngle parent.vec.angle
      startVec = @getValidStart parent, a
      start    = parent.start.add startVec
    else
      start = new paper.Point(0, 0)
      a = @firstBranchAngles.seedRandom('addBranch2')
    
    maxLength = @minBranchLength + rng('addBranch3') * (@maxBranchLength-@minBranchLength)
    maxLength *= 1 - ( (@branches.length+1) / @maxBranches)
    maxLength = Math.max(maxLength, @minBranchLength)

    vec = new paper.Point()
    vec.angle = a
    vec.length = 1
    
    path = new paper.Path()
    path.strokeColor = @branchColor
    path.strokeWidth = @branchWidth
    path.add start
    path.add start.add(vec)
    path.visible = false
    @view.addChild path
    
    b = 
      start       : start
      angle       : a
      startLength : startVec.length
      vec         : vec
      path        : path
      parent      : parent
      maxLength   : maxLength
      children    : []
      items       : []
    @branches.push b

    if parent
      parent.children.push b

  addTrackPoint: (view) ->

    parent   = @branches.seedRandom('addTrackPoint1')
    startVec = new paper.Point()
    startVec.angle = parent.vec.angle
    startVec.length = parent.maxLength * (rng('addTrackPoint2')*0.5+0.5)
    start = parent.start.add startVec

    if view
      @view.addChild view
      view.scaling = 0.1
      view.visible = false

    p =
      start       : start
      startLength : startVec.length
      parent      : parent
      view        : view
      ref         : @view
      scale       : 0.1
      pos         : new paper.Point()
    @trackPoints.push p

    parent.items.push p
    
    return p

  newBranchTick: () =>
    if @branches.length < @maxBranches
      @addBranch()
      for b in @branches
        b.path.strokeWidth = Math.min(@maxBranchWidth, b.path.strokeWidth+0.3)
    return