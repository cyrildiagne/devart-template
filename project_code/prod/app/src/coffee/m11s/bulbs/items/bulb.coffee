class mk.m11s.bulbs.BulbSocket

  constructor: (@view, @follower, @mirrored, radius) ->
    @symbol = mk.m11s.bulbs.BulbSocket.symbol
    @item = @symbol.place()
    @item.position.x = radius + @item.bounds.width * 0.5 - 1
    @view.addChild @item
    @view.pivot = new paper.Point(radius + @item.bounds.width, 0)
    @view.rotation = @initRotation = if @mirrored then 180 - 25 else 25
    @velTracker = new mk.helpers.JointVelocityTracker [@follower.j2]
    @bounce = 0
    @freq = 0

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
    @amp = @freq * 120
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

  maxRays : 0
  numRays : 0
  
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
    # @bulb.style.fillColor = @colorLightsOff
    # @halo.style.fillColor = @haloLightsOff
    @halo.visible = true
    @areLightsOn = true

    # c.line.strokeColor = @lineColorOn for c in @connections

  lightsOff: ->
    # @bulb.style.fillColor = @colorOff
    # @halo.style.fillColor = @haloColorOff
    @halo.visible = false
    @areLightsOn = false

    # c.line.strokeColor = @lineColorOff for c in @connections
      
  update: (dt) ->
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
      if d > 30000
        c.line.remove()
        mk.m11s.bulbs.Bulb::numConnections--
        @connections.splice @connections.indexOf(c),1
      else
        c.line.segments[0].point.x = @view.position.x
        c.line.segments[0].point.y = @view.position.y
        c.line.segments[1].point.x = c.bulb.view.position.x
        c.line.segments[1].point.y = c.bulb.view.position.y
        c.line.dashOffset += 1

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
    line.z = 9999
    line.strokeColor = @lineColorOff #if @areLightsOn then @lineColorOn else @lineColorOff
    # line.opacity = 0.5
    line.strokeWidth = 2
    line.dashArray = [10, 5]
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

    