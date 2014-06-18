class mk.m11s.stripes.Ball

  constructor : (p, radius) ->
    @view = new paper.Path.Circle p, radius
    # @stroke = new paper.Path.Circle
    #   center : p
    #   radius : radius
    # @stroke.strokeColor = 'black'
    @body = null

class mk.m11s.stripes.Rectangle

  constructor : (p, width, height) ->
    @view = new paper.Path.Rectangle [0,0], width, height
    @view.position = new paper.Point p
    @view.transformContent = false
    # @stroke = new paper.Path.Circle
    #   center : p
    #   radius : radius
    # @stroke.strokeColor = 'black'
    @body = null


class mk.m11s.stripes.FallingItems
  
  constructor : (@physics) ->
    @view = new paper.Group()
    @view.z = 1500

    @viewVisible = new paper.Group()

    @items = []
    @itemsToAdd = []
    @maxItems = 12

    @shapeMode = 'circle'
    @popMode = 'top'
    @itemIntervalTime = 5000

    @lastRectBottomSide = 1

    @scale = 1

  setMode : (mode) ->
    @popMode = mode
    gx = 0
    gy = 1
    switch @popMode
      when 'top', 'bottom'
        @shapeMode = 'circle'
        if @popMode is 'bottom' then gy = -1
      when 'left'
        @shapeMode = 'rect'
        @maxItems = 25
        @itemIntervalTime = 200
        gx = 2
        gy = 0
      when 'all'
        @shapeMode = 'circle'
        @maxItems = 40
        @itemIntervalTime = 500
        gy = 0
    @physics.tweenGravity gx,gy, 3000

  addItem : (opt) ->
    rngk = 'additem'
    p = opt.pos || new paper.Point()
    offset = opt.radius || 0

    switch @popMode

      when 'top', 'bottom'
        p.x = (rng(rngk)-0.5) * window.viewport.width * 0.8
        p.y = -window.viewport.height * 0.5 - offset
        if @popMode is 'bottom' then p.y *= -1
      when 'left'
        p.x = -window.viewport.width * 0.5 - offset
        p.y = (rng(rngk)-0.5) * window.viewport.height * 0.8
      when 'all'
        side = rngi(rngk,1,4)
        switch side
          when 1,2 # top, bottom
            p.x = (rng(rngk)-0.5) * window.viewport.width * 0.8
            p.y = window.viewport.height * 0.5 +   offset * 2
          when 3,4 # left, right
            p.x = window.viewport.width * 0.5 + offset * 2
            p.y = (rng(rngk)-0.5) * window.viewport.height * 0.8
        p.y *= -1 if side is 2
        p.x *= -1 if side is 4

    restitution = 1
    if @popMode is 'all'
      restitution = 0
    switch @shapeMode

      when 'circle'
        item = new mk.m11s.stripes.Ball p, opt.radius
        item.body = @physics.addCircle item.view, p, opt.radius,
          restitution: restitution
          friction : 0.0
        item.position = p
      when 'rect'
        if @popMode is 'bottom'
          p.x = window.viewport.width * 0.4 * (@lastRectBottomSide*=-1)
          p.y = window.viewport.height * 0.5
          w = opt.width
          opt.width = opt.height
          opt.height = w
        else
          p.y = -window.viewport.height * 0.3
        item = new mk.m11s.stripes.Rectangle p, opt.width, opt.height
        item.body = @physics.addRectangle item.view, p, opt.width, opt.height,
          restitution: restitution
          friction : 0.0
        item.position = p

    @items.push item
    # @viewVisible.addChild item.stroke
    @view.addChild item.view

  intervalItem : =>
    if !@lockPop
      switch @shapeMode
        when 'circle'
          radius = 30 + rng('iball')*80
          @itemsToAdd.push {type:'circle', radius:radius}
        when 'rect'
          @itemsToAdd.push {type:'rect', width:10, height:250}

    if @itemIntervalTime > 500 + 1000
      @itemIntervalTime -= 1000
    delayed @itemIntervalTime, @intervalItem

  update : (dt) ->

    if @popMode is 'all'
      @scale *= 0.999
      for item in @items
        item.view.scale 1.001
        b = item.body
        # if @scale > 0.1
        #   Matter.Body.scale b, 0.999, 0.999
        Matter.Body.applyForce b, b.position, Matter.Vector.mult(b.position, -0.00002)
    # for b in @items.itemsToAdd
    #   b.stroke.position.x = b.body.position.x
    #   b.stroke.position.y = b.body.position.y

    if @itemsToAdd.length > 0
      if @items.length >= @maxItems
        @removeOldest()
      item = @itemsToAdd.shift()
      @addItem item
    return null

  clear : ->
    @removeOldest() while @items.length

  removeOldest : ->
    item = @items.shift()
    @physics.remove(item.body)
    # item.stroke.remove() if item.stroke
    item.view.remove()