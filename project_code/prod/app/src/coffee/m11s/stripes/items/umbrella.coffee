class mk.m11s.stripes.Umbrella

  constructor : (@physics, @part) ->

    @w = 250
    @h = 80
    @y = -200
    @isStatic = true

    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point @w*0.5, -@h*0.5

    @view.scaling = 0.01
    v = @view
    new TWEEN.Tween({s:0.01})
    .to({s:1}, 500)
    .onUpdate(-> v.scaling = @s)
    .start window.currentTime

    vector = new paper.Point 0, -@h*1.35
    @top = new paper.Path
      segments: [
        [[0,  0], null, vector],
        [[@w, 0], vector, null]
      ],
      fillColor : 'black'
    @view.addChild @top

    @dRot = 0

    @stick = new paper.Path.Rectangle [@w*0.5-2, 0], [4, -@y-@h*0.5+15]
    @view.addChild @stick

    @body = Matter.Bodies.rectangle 0, @y, @w, @h,
      chamfer:
        radius: [90, 90, 0, 0]
      isStatic: @isStatic = true
    @body.view = @view

    Matter.World.add @physics.engine.world, @body
    @physics.bodies.push
      body : @body
      view : @view

    mk.Scene::sfx.play 'umbrella_in'

  setStatic : (@isStatic) ->
    if !@isStatic
      mk.Scene::sfx.play 'umbrella_out'
    # Matter.Body.setStatic @body, @isStatic

  update : (dt) ->
    
    if !@isStatic #then return
      Matter.Body.translate @body, {x:0,y:-4}
      Matter.Body.rotate @body, 0.02
      return

    @dRot += (@part.getAngle() * 0.2 - @dRot) * 0.005 * dt

    bRot = @body.angle
    bPos = @body.position

    dPos = @part.joints[1]
    dPos.x += @y * Math.sin(-@dRot)
    dPos.y += @y * Math.cos(-@dRot)

    Matter.Body.translate @body,
      x : dPos.x - bPos.x
      y : dPos.y - bPos.y

    Matter.Body.rotate @body, @dRot - bRot