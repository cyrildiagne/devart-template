class mk.m11s.lockers.Balloon

  constructor: (@hand) ->
    @nbItems              = 12
    @ropeLength           = 100 + rng('blnc')*500
    @relaxationIterations = 10
    @pixelsPerMeter       = 200
    @gravity              = -30 - rng('bln')*20
    @handleId             = @nbItems-1

    @items = []
    @mouse = new paper.Point()

    @forceX = (rng('blnf')-0.5)*30

    @view = new paper.Group()
    @view.transformContent = false

    @path = new paper.Path
      strokeColor: mk.Scene::settings.getHexColor 'cream'
      strokeWidth: 2
    @view.addChild @path
    
    origin = new paper.Point @hand.x, @hand.y
    for i in [0...@nbItems]
      x = origin.x # i * @ropeLength / @nbItems * 0.1
      y = origin.y
      @items[i] =
        x: x
        y: y
        prev_x: x
        prev_y: y
        isPinned: false
      @path.add new paper.Point(x, y)

    @circle = new paper.Path.Circle
      center : [0,0]
      radius : 60+rng('bln')*80
      fillColor : mk.Scene::settings.getHexColor ['lightRed','beige','blue'].seedRandom('crcl')
    @circle.transformContent = false
    @circle.scaling = 0.01
    @view.addChild @circle

    c = @circle
    tween = new TWEEN.Tween({s:0.01})
    .to({s:1},1000)
    .onUpdate(-> c.scaling = @s )
    .start window.currentTime

  update: (delta) ->
    @updateHandle()
    @updatePhysics delta * 0.001, @ropeLength / @nbItems

    for item,i in @items
      @path.segments[i].point.x = item.x
      @path.segments[i].point.y = item.y

    @path.segments.last().point.x = @hand.x
    @path.segments.last().point.y = @hand.y

    @path.smooth()

    @circle.position.x = @path.segments[0].point.x
    @circle.position.y = @path.segments[0].point.y

  updateHandle: ->
    sp = @path.segments[@handleId].point
    @items[@handleId].x = @hand.x
    @items[@handleId].y = @hand.y
    @items[@handleId].x += @forceX

  # http://charly-studio.com/blog/html5-rope-simulation-verlet-integration-and-relaxation/

  updatePhysics: (ellapsedTime, itemLength) ->
    # Apply verlet integration
    for item in @items
      prev_x = item.x
      prev_y = item.y
      if !item.isPinned
        @applyUnitaryVerletIntegration item, ellapsedTime
      item.prev_x = prev_x
      item.prev_y = prev_y
    
    # Apply relaxation
    for it in [0...@relaxationIterations]
      for item,i in @items
        if !item.isPinned
          if i > 0
            previous = @items[i - 1]
            @applyUnitaryDistanceRelaxation item, previous, itemLength
      for item,i in @items
        item = @items[@nbItems - 1 - i]
        if !item.isPinned
          if i > 0
            next = @items[@nbItems - i]
            @applyUnitaryDistanceRelaxation item, next, itemLength
    return

  applyUnitaryVerletIntegration: (item, ellapsedTime) ->
    item.x = 2 * item.x - item.prev_x
    item.y = 2 * item.y - item.prev_y + @gravity * ellapsedTime * ellapsedTime * @pixelsPerMeter

  applyUnitaryDistanceRelaxation: (item, from, targettedLength) ->
    dx = item.x - from.x
    dy = item.y - from.y
    dstFrom = Math.sqrt(dx * dx + dy * dy)
    if dstFrom > targettedLength and dstFrom != 0
      item.x -= (dstFrom - targettedLength) * (dx / dstFrom) * 0.5
      item.y -= (dstFrom - targettedLength) * (dy / dstFrom) * 0.5



class mk.m11s.lockers.Balloons

  constructor : (@leftHand, @rightHand) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 9999

    @balloons = []
    
  addBalloon : ->
    b = new mk.m11s.lockers.Balloon @rightHand
    @view.addChild b.view
    @balloons.push b

  update : (dt) ->
    b.update dt for b in @balloons