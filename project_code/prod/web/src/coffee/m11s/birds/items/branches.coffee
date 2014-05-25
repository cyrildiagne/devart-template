class mk.m11s.birds.Branches

  constructor: (@j1, @j2, @pct, options) ->
    @branchColor                = "#B5CEC0"
    @branchWidth                = 2
    @maxBranchWidth             = 10
    @maxBranches                = 10
    @minBranchLength            = 50
    @maxBranchLength            = 500
    @growSpeed                  = 0.01
    @timeBetweenBranches        = 2000
    @minDistanceBetweenBranches = 8
    @firstBranchAngles          = [-135, -45]

    @[k] = v for k, v of options

    @view = new paper.Group()
    @view.z = 0
    @view.transformContent = false
    @view.pivot = new paper.Point(0, 0)

    @follower = new mk.m11s.PartEdgeFollower @view, @j1, @j2, @pct
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

      b.vec.length += (b.maxLength-b.vec.length) * @growSpeed
      b.currVec = b.vec.clone()
      b.currVec.angle = b.angle - @velocity * (i*1.5+1)

      b.path.segments[0].point = b.currStart
      b.path.segments[1].point = b.currStart.add b.currVec

    for tp,i in @trackPoints
      tp.view.position = tp.parent.currStart.add tp.parent.currVec.normalize( tp.startLength )

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
      startVec.length = parent.vec.length * (rng('getValidStart')*0.5+0.5)
      start = parent.start.add(startVec)
      break if ++tries > 10 || @hasFreeSpace(start, a)
    return startVec

  addBranch: () ->
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
    @view.addChild path
    
    @branches.push
      start       : start
      angle       : a
      startLength : startVec.length
      vec         : vec
      path        : path
      parent      : parent
      maxLength   : maxLength

  addTrackPoint: (view) ->

    parent   = @branches.seedRandom('addTrackPoint1')
    startVec = new paper.Point()
    startVec.angle = parent.vec.angle
    startVec.length = parent.vec.length * (rng('addTrackPoint2')*0.5+0.5)
    start = parent.start.add startVec

    @view.addChild view

    p =
      start       : start
      startLength : startVec.length
      parent      : parent
      view        : view

    @trackPoints.push p
      
    return p

  newBranchTick: () =>
    if @branches.length < @maxBranches
      @addBranch()
      for b in @branches
        b.path.strokeWidth = Math.min(@maxBranchWidth, b.path.strokeWidth+0.3)
    return