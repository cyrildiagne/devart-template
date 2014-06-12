class mk.m11s.bulbs.Rope

  constructor: (@joints, @colors) ->
    @nbItems              = 12
    @ropeLength           = 500
    @relaxationIterations = 10
    @pixelsPerMeter       = 200
    @gravity              = 9.81
    @handleId             = @nbItems-1

    @view = new paper.Group()
    @view.z = 9999

    @items = []
    @mouse = new paper.Point()

    @currJointDragging = null

    @setup()

  setup: ->
    @path = new paper.Path
      strokeColor: '#' + @colors.cream.toString(16),
      strokeWidth: 4
    @view.addChild @path
    
    @handle = new paper.Path.Circle
        fillColor: '#' + @colors.blue.toString(16),
        radius: 10
    @view.addChild @handle
    
    origin = new paper.Point(-150, -window.viewport.height*0.5)
    for i in [0...@nbItems]
        x = origin.x + i * @ropeLength / @nbItems * 0.1
        y = origin.y
        @items[i] =
          x: x
          y: y
          prev_x: x
          prev_y: y
          isPinned: false
        @path.add new paper.Point(x, y)

    @items[0].isPinned = true

  yoyo: ->
    initY = -window.viewport.height*0.5
    item = @items[0]
    delay = 5000
    delay = 5000 if Config::DEBUG
    back  = new TWEEN.Tween(item).delay(delay).to({y:initY}, 1000)
    back.onStart => 
      @ropeLength = 500 + (rng('ropeyoyo')-0.3) * 200
      newX = (rng('ropeyoyo')-0.4) * window.viewport.width
      i = 0
      for it in @items
        it.x = it.prev_x = newX + i * @ropeLength / @nbItems * 0.1
        it.y = it.prev_y = initY
        i++
    tween = new TWEEN.Tween(item).to({y:-window.viewport.height*0.5-700}, 1000)
    # .repeat(1)
    # .yoyo()
    .chain(back)
    .start(window.currentTime)

  update: (delta) ->
    @updatePhysics delta * 0.001, @ropeLength / @nbItems
    for item,i in @items
        @path.segments[i].point.x = item.x
        @path.segments[i].point.y = item.y
    @path.smooth()
    @updateHandle()

  updateHandle: ->
    sp = @path.segments[@handleId].point
    isDragging = false
    for j in @joints
      jp = new paper.Point(j.x, j.y)
      d = jp.getDistance sp
      if d < 75
        diff = jp.subtract sp
        @items[@handleId].x += diff.x*0.9
        @items[@handleId].y += diff.y*0.9
        if !@currJointDragging
          @currJointDragging = j
          if @onLightsOff then @onLightsOff()
        isDragging = true
        break
    if @currJointDragging and !isDragging
      @currJointDragging = null
      if @onLightsOn then @onLightsOn()
    @handle.position = @path.segments[@handleId].point

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

