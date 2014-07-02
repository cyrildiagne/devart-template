class mk.m11s.books.Whale

  constructor : (@onAnimationComplete) ->
    @view = new paper.Group()
    @view.pivot = new paper.Point 0,0
    @view.transformContent = false
    @view.z = -4444

    @setupMask()
    @mask.position.y -= 450

    @head = new paper.Point
      angle: 0
      length: 250
    @tail = new paper.Point
      angle: 180
      length: 220

    @dest = new paper.Point()
    @position = new paper.Point()
    @angle = 0
    @tailAngle = 0
    @width = 400
    @maxJumps = 7
    
    @path = new paper.Path()
    @path.fillColor = mk.Scene::settings.getHexColor 'cream'
    @path.segments = [
      [[0, 0], null, @head.rotate(45)]
      [[0+@width, 0], @head.rotate(180), @head.rotate(180)]
      [[0, 0], @head.rotate(-45), null]
    ]
    @view.addChild @path

    @time = 0
    @numJumps = 0
    @jumping = false
    @jump()
    @view.visible = false

  setupMask : ->
    vw = window.viewport.width
    vh = window.viewport.height
    @mask = new paper.Path.Rectangle [-vw*0.5, -vh*0.5], [vw, vh]
    @view.addChild @mask
    @view.clipped = true

  jump : ->
    if @jumping then return
    # s = 0.1+(@numJumps++)*0.4
    s = rng('jmp')*3 + 0.2
    console.log 'whale jump num : ' + @numJumps
    
    # if @numJumps > 6 then @view.z = 2000
    # else if @numJumps > 4 then @view.z = 0

    @view.scaling = new paper.Point s,s
    # if rng('jump') > 0.5 then @view.scaling.x *= -1
    # console.log @view.scaling.x

    @view.position.x = rng('jump') * window.viewport.width * 0.5
    if view.scaling.x < 0 then @view.position.x *= -1

    # if @numJumps is @maxJumps
    #   @view.position.x = -600
    #   @view.scaling = 3.5

    @time = Math.PI * 0.8
    @jumping = true
    @view.visible = true

  update : (dt) ->
    if !@jumping then return

    @time += dt / 1000 * 1.5
    @dest.x = Math.cos(@time)*200
    @dest.y = Math.sin(@time)*800 + 300

    if @time > 2.5 * Math.PI
      @jumping = false
      @view.visible = false
      if @numJumps is @maxJumps
        @onAnimationComplete()
      return

    vel = @dest.subtract(@position).multiply(0.1)
    @position = @position.add vel
    @angle += (vel.angle - @angle) * 0.1

    @head.angle = @angle
    
    @path.segments[0].point.x = @path.segments[2].point.x = @position.x
    @path.segments[0].point.y = @path.segments[2].point.y = @position.y
    @path.segments[0].handleOut = @head.rotate(180 + 45)
    @path.segments[2].handleIn = @head.rotate(180 - 45)

    @tailAngle += (@head.angle - @tailAngle) * 0.03
    @tail.angle = @tailAngle

    @path.segments[1].handleIn = @tail
    @path.segments[1].handleOut = @tail

    @body = @head.clone()
    @body.length = @width

    dx = @path.segments[0].point.x - @body.x
    dy = @path.segments[0].point.y - @body.y
    p = @path.segments[1].point
    p.x += (dx - p.x) * 0.1
    p.y += (dy - p.y) * 0.1