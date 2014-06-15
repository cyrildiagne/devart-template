class mk.m11s.bulbs.BulbSocket

  constructor: (@view, @follower, @mirrored, radius) ->
    @symbol = mk.m11s.bulbs.BulbSocket.symbol
    @item = @symbol.place()
    @item.position.x = radius + @item.bounds.width * 0.5 - 1
    @view.addChild @item
    @view.pivot = new paper.Point(radius + @item.bounds.width, 0)
    @view.rotation = @initRotation = if @mirrored then 180 - 25 else 25
    @velTracker = new mk.helpers.JointVelocityTracker [@follower.j2]
    @side = if @mirrored then 1 else -1
    @bounce = 0
    @freq = 0
    @ang = 120

  update: () ->
    @velTracker.update()
    pct = 1 - @follower.pct
    trackerSpeed = @velTracker.get(0)
    delta = (trackerSpeed * 0.01 * pct - @freq)
    speed = if delta > 0 then 0.1 else 0.02
    @freq += delta * speed
    @freq = Math.min(@freq, 0.4)
    phase = Math.cos(@bounce+=@freq)+1
    if @mirrored then phase *= -1
    @amp = @freq * @ang
    dRot = @initRotation + phase * @amp
    @view.rotation = dRot


class mk.m11s.bulbs.Ray

  constructor: ->
    @view = new paper.Path()
    @view.pivot = new paper.Point 0,0
    @view.segments = [
      [0, 0]
      [-800, 0]
      [-800, 0]
    ]
    @thick = 50
    @view.fillColor = mk.Scene::settings.getHexColor 'lightRed'
    @view.opacity = 0.5
    @view.visible = false

    @isShowing = false

    @tween = null

  clean : ->
    if @tween then @tween.stop()

  show: ->
    mk.Scene::sfx.play 'laserOn'
    v = @view
    thick = @thick
    @tween = new TWEEN.Tween({amp:0})
    .to({amp:1}, 600)
    .onUpdate(->
      v.segments[1].point.x = -800 * @amp
      v.segments[1].point.y = -thick * @amp
      v.segments[2].point.x = -800 * @amp
      v.segments[2].point.y = thick * @amp
    )
    .start window.currentTime
    @view.visible = true
    @isShowing = true

  hide: (callback) ->
    mk.Scene::sfx.play 'laserOff'
    v = @view
    thick = @thick
    @tween = new TWEEN.Tween({amp:1})
    .to({amp:0}, 300)
    .onUpdate(->
      v.segments[1].point.y = -thick * @amp
      v.segments[2].point.y = thick * @amp
    )
    .onComplete(=>
      v.visible = false
      @isShowing = false
      callback() if callback
    )
    .start window.currentTime


class mk.m11s.bulbs.Bulb

  maxConnection : 0
  numConnections : 0

  maxRays : 1
  numRays : 0

  floatPower : 0.2
  
  constructor: (@part, @pct, @defaultColorOff, @defaultColorOn, id) ->
    @rngk = 'Bulb' + id
    @radius = 12
    @haloRadius = 30
    @view = new paper.Group()
    @view.z = 0
    @view.pivot = new paper.Point 0,0
    @view.transformContent = false
    @power = rng(@rngk) * Math.PI
    @freq = (rng(@rngk) * 0.5 + 0.5) * Math.PI * 0.05
    @interval = 0
    @blinkTime = 7000 * rng(@rngk)
    @setupStyles()
    @draw()
    @areLightsOn = false
    @turnedOn = false
    @isActive = false
    @connections = []
    @ray = null
    @isFloating = false
    @floatFollower = null
    @prevPos = null
    if @pct > 0.001
      @follower = new mk.helpers.PartEdgeFollower @view, @part.joints[0], @part.joints[1], @pct
      mirrored = @part.name.indexOf('right') isnt -1
      @socket = new mk.m11s.bulbs.BulbSocket @view, @follower, mirrored, @radius
    else
      @follower = new mk.helpers.JointFollower @view, @part.joints[0], 200
      @halo.radius = 40

  setupStyles: ->
    @colorOff = new paper.Color ('#' + @defaultColorOff.toString(16))
    @colorOff.alpha = 0.8
    @haloColorOff = @colorOff.clone()
    @haloColorOff.alpha = 0.0

    @colorOn = new paper.Color ('#' + @defaultColorOn.toString(16))
    @colorOn.alpha = 0.8
    @haloColorOn = @colorOn.clone()
    @haloColorOn.alpha = 0.5

    @colorLightsOff = @colorOff.clone() #new paper.Color '#fff'
    @haloLightsOff = @colorLightsOff.clone()
    @haloLightsOff.alpha = 0.5

    @white = new paper.Color 'white'

    @lineColorOn = mk.Scene::settings.getHexColor 'lightRed'
    @lineColorOff = mk.Scene::settings.getHexColor 'lightBlue'

  draw: ->
    @halo = new paper.Path.Circle
      radius : @haloRadius
      fillColor : @haloColorOff
    @halo.visible = false
    @view.addChild @halo

    @bulb = new paper.Path.Circle
      radius : @radius
      fillColor : @colorOff
    @view.addChild @bulb

  lightsOn: ->
    @halo.visible = true
    @areLightsOn = true

  lightsOff: ->
    @halo.visible = false
    @areLightsOn = false
      
  update: (dt) ->
    if !@isFloating
      @follower.update()
      if @socket
        @socket.update()

    phase = Math.cos(@power+=@freq)+1
    @haloColorOn.alpha = @haloColorOff.alpha = @haloLightsOff.alpha = phase * 0.20 + 0.11
    

  # 1 --- RED BLINK + RAYS

  updateRedBlink: (dt) ->
    @interval += dt
    if @interval >= @blinkTime
      @interval -= @blinkTime
      if !@turnedOn
        @turnOn()
      else @turnOff()
      @blinkTime = if @turnedOn then 2000 else 2000 + 8000 * rng(@rngk)

  stopRedBlink : ->
    if @turnedOn then @turnOff()

  turnOn: ->
    @bulb.style.fillColor = @colorOn
    @halo.style.fillColor = @haloColorOn
    @halo.visible = true
    @turnedOn = true
    if @ray
      if mk.m11s.bulbs.Bulb::numRays < mk.m11s.bulbs.Bulb::maxRays
        mk.m11s.bulbs.Bulb::numRays++
        @ray.show()

  turnOff: ->
    @bulb.style.fillColor = @colorOff
    @halo.style.fillColor = @haloColorOff
    @halo.visible = false
    @turnedOn = false
    if @ray && @ray.isShowing
      @ray.hide ->
        mk.m11s.bulbs.Bulb::numRays--

  setupRay : ->
    @ray = new mk.m11s.bulbs.Ray()
    @ray.view.visible = @turnedOn
    @view.addChild @ray.view

  removeRay : ->
    @turnOff()
    if @ray.isShowing
      mk.m11s.bulbs.Bulb::numRays--
    @ray.clean()
    @ray.view.remove()
    @ray = null

  # 2 --- CONNECTED BULBS

  updateConnections : (dt) ->
    for i in [@connections.length-1..0] by -1
      c = @connections[i]
      p1 = @view.position
      p2 = c.bulb.view.position
      d = (p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y)
      if d > 22000
        c.line.remove()
        mk.m11s.bulbs.Bulb::numConnections--
        @connections.splice @connections.indexOf(c),1
      else
        c.line.segments[0].point.x = @view.position.x
        c.line.segments[0].point.y = @view.position.y
        c.line.segments[1].point.x = c.bulb.view.position.x
        c.line.segments[1].point.y = c.bulb.view.position.y
        # c.line.dashOffset += 1

  connectToNearbyBulbs : (bulbs) ->
    for b in bulbs
      if mk.m11s.bulbs.Bulb::numConnections >= mk.m11s.bulbs.Bulb::maxConnection then return
      if b.part is @part then continue
      if !@isConnectedTo(b) and !b.isConnectedTo(@)
        p1 = @view.position
        p2 = b.view.position
        d = (p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y)
        if d < 20000 #200*200
          @connectToBulb(b)

  connectToBulb : (b) ->
    line = new paper.Path.Line @view.position, b.view.position
    line.z = 4999 + rng('connectbulb') * 100
    line.strokeColor = @lineColorOff
    # line.opacity = 0.5
    line.strokeWidth = 3
    # line.strokeCap = 'round'
    # line.dashArray = [0.5, 12]
    @connections.push
      bulb : b
      line : line
    mk.m11s.bulbs.Bulb::numConnections++

  isConnectedTo : (b) ->
    for c in @connections
      return true if c.bulb is b
    return false

  removeConnections : ->
    for c in @connections
      c.line.remove()
      mk.m11s.bulbs.Bulb::numConnections--
    @connections.splice 0, @connections.length

  # 3 --- FLOATING

  startFloating : ->
    return if !@socket
    @isFloating = true
    @floatFollower = new mk.helpers.FloatFollower @view
    @view.rotation = @socket.initRotation
    @view.z = 9999
    # @socket.amp = 60 if @socket

  updateFloating : (dt) ->
    return if !@socket
    x = 0
    y = 0
    # @socket.update() if @socket
    if @follower.joint
      x = @follower.joint.x
      y = @follower.joint.y
      # @view.z = @follower.joint.z + 50
    else
      x = @follower.j1.x * @follower.pct + @follower.j2.x * (1-@follower.pct)
      y = @follower.j1.y * @follower.pct + @follower.j2.y * (1-@follower.pct)
      # @view.z = @follower.j1.z * @follower.pct + @follower.j2.z * (1-@follower.pct) + @follower.zOffset
    @floatFollower.dest.x = x
    @floatFollower.dest.y = y
    if @prevPos
      rt = Math.sqrt (@prevPos.x-x)*(@prevPos.x-x) + (@prevPos.y-y)*(@prevPos.y-y)
      # if rt > 10
      @floatFollower.dist += rt * mk.m11s.bulbs.Bulb::floatPower
      @floatFollower.speed = Math.max(0.005, rt * 0.0001)
    @floatFollower.dist += (0-@floatFollower.dist) * 0.0025 * dt
    @floatFollower.update dt
    if @socket
      if @floatFollower.dist > 15
        @bulb.style.fillColor = @white
        @view.rotation = @socket.side * @floatFollower.ang / Math.PI * 180
      else
        @bulb.style.fillColor = @colorOff
        @view.rotation +=  (@socket.initRotation - @view.rotation)*0.005*dt
    @prevPos = {x:x, y:y}

  stopFloating : ->
    # @socket.amp = 120 if @socket
    return if !@socket
    @bulb.style.fillColor = @colorOff
    @isFloating = false
    @floatFollower = null