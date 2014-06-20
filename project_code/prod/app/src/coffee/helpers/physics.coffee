class mk.helpers.Physics
  
  constructor : ->

    CustomRenderer =
      # input :
      #   mouse : {}
      create : (options) ->
        return @
      world : (engine) ->
        return

    @engine = Matter.Engine.create
      positionIterations: 6
      velocityIterations: 4
      enableSleeping: true
      render:
        controller: CustomRenderer
        options:
          something: true
      world :
        bounds :
          min: { x: 0, y: 0 }
          max: { x: window.viewport.width * 2, y: window.viewport.height } 

    @bodies = []
    @persoPartBodies = []
    @persoJointBodies = []

  addFloor : ->
    floor = Matter.Bodies.rectangle 0, window.viewport.height*0.5, window.innerWidth + 100, 50,
      isStatic : true
    Matter.World.add @engine.world, floor

  addPersoPartRect : (part) ->
    x = 0
    y = 0
    width = height = 10
    angle = 0
    body = Matter.Bodies.rectangle x, y, width, height,
      isStatic: true
      angle : angle
    Matter.World.add @engine.world, body

    ppb =
      body : body
      part : part

    @updatePersoPartRect ppb
    @persoPartBodies.push ppb

  addPersoJoint : (jnt, opt) ->
    opt = {} if !opt
    opt.isStatic = true
    body = Matter.Bodies.circle jnt.x, jnt.y, jnt.radius, opt, 10
    Matter.World.add @engine.world, body

    pjb =
      body : body
      joint : jnt

    @updatePersoJoint pjb
    @persoJointBodies.push pjb

  updatePersoPartRect : (ppb) ->

    j1 = ppb.part.joints[0]
    j2 = ppb.part.joints[1]
    x = (j1.x + j2.x) * 0.5
    y = (j1.y + j2.y) * 0.5
    dx = j1.x - j2.x
    dy = j1.y - j2.y
    width = Math.sqrt(dx*dx + dy*dy)
    height = Math.min j1.radius*2, j2.radius*2
    height *= 1.5
    angle = Math.atan2(dy, dx)

    body = ppb.body
    body.position.x = x
    body.position.y = y

    body.vertices[0].x = x - width * 0.5
    body.vertices[0].y = y - height * 0.5
    body.vertices[1].x = x + width * 0.5
    body.vertices[1].y = y - height * 0.5
    body.vertices[2].x = x + width * 0.5
    body.vertices[2].y = y + height * 0.5
    body.vertices[3].x = x - width * 0.5
    body.vertices[3].y = y + height * 0.5

    Matter.Vertices.rotate body.vertices, angle, body.position

    # @updatePaperDebug ppb

  updatePersoJoint : (pjb) ->
    dx = pjb.joint.x - pjb.body.position.x
    dy = pjb.joint.y - pjb.body.position.y
    Matter.Body.translate pjb.body, {x:dx,y:dy}

  updatePaperDebug : (ppb) ->
    if !ppb.debug
      ppb.debug = new paper.Path()
      for i in [0...4]
        ppb.debug.add [0, 0]
      ppb.debug.z = 9999
      ppb.debug.strokeColor = 'red'
    for i in [0...4]
      ppb.debug.segments[i].point = ppb.body.vertices[i]
    return null

  addCircle : (view, pos, radius, opt) ->
    circle = Matter.Bodies.circle pos.x, pos.y, radius, opt, 10
    circle.view = view
    Matter.World.add @engine.world, circle
    @bodies.push 
      body : circle
      view : view
    return circle

  addRectangle : (view, pos, width, height, opt) ->
    rect = Matter.Bodies.rectangle pos.x, pos.y, width, height, opt, 10
    rect.view = view
    Matter.World.add @engine.world, rect
    @bodies.push 
      body : rect
      view : view
    return rect

  tweenGravity : (x, y, duration) ->
    # g = @getGravity()
    # ph = @
    # ph.setGravity 0,0
    # new TWEEN.Tween({x:0, y:0}, duration*0.5)
    # .to({x:x,y:y})
    # .delay(duration*0.5)
    # .onUpdate(->
    @setGravity x, y
    # ).start window.currentTime

  setGravity : (x,y) ->
    if x isnt null and x isnt undefined
      @engine.world.gravity.x = x
    if y isnt null and y isnt undefined
      @engine.world.gravity.y = y

  getGravity : () ->
    return @engine.world.gravity

  remove : (body) ->
    Matter.World.remove @engine.world, body
    for i in [0...@bodies.length]
      b = @bodies[i]
      if b.body is body
        @bodies.splice(i,1)
        return

  update : (dt) ->
    Matter.Engine.update @engine, 1000/60, 1
    for b in @bodies
      b.view.position.x = b.body.position.x
      b.view.position.y = b.body.position.y
      b.view.rotation = b.body.angle / Math.PI * 180
    
    for ppb in @persoPartBodies 
      @updatePersoPartRect ppb

    for pjb in @persoJointBodies 
      @updatePersoJoint pjb
    return null
    