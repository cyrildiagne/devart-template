class mk.m11s.bulbs.BulbSocket

  constructor: (@view, @follower, @mirrored, radius) ->
    @symbol = mk.m11s.bulbs.BulbSocket.symbol
    @item = @symbol.place()
    @item.position.x = radius + @item.bounds.width * 0.5 - 1
    @view.addChild @item
    @view.pivot = new paper.Point(radius + @item.bounds.width, 0)
    @view.rotation = @initRotation = if @mirrored then 180 - 25 else 25
    @velTracker = new mk.m11s.JointVelocityTracker [@follower.j2]
    @bounce = 0
    @freq = 0

  update: () ->
    @velTracker.update()
    pct = 1 - @follower.pct
    trackerSpeed = toPt @velTracker.get(0)
    delta = (trackerSpeed * 0.005 * pct - @freq)
    speed = if delta > 0 then 0.1 else 0.02
    @freq += delta * speed
    @freq = Math.min(@freq, 0.4)
    phase = Math.cos(@bounce+=@freq)+1
    if @mirrored then phase *= -1
    @amp = @freq * 120
    dRot = @initRotation + phase * @amp
    @view.rotation = dRot


class mk.m11s.bulbs.Bulb
  
  constructor: (@part, @pct, @defaultColorOff, @defaultColorOn) ->
    @radius = 12
    @haloRadius = 35
    @view = new paper.Group()
    @view.z = 0
    @view.transformContent = false
    @power = Math.random() * Math.PI
    @freq = (Math.random()*0.5 + 0.5) * Math.PI * 0.05
    @setupStyles()
    @draw()
    @areLightsOff = false
    if @pct > 0.001
      @follower = new mk.m11s.PartEdgeFollower @view, @part.joints[0], @part.joints[1], @pct
      mirrored = @part.name.indexOf('right') isnt -1
      @socket = new mk.m11s.bulbs.BulbSocket @view, @follower, mirrored, @radius
    else
      @follower = new mk.m11s.JointFollower @view, @part.joints[0]

  setupStyles: ->
    @colorOff = new paper.Color ('#' + @defaultColorOff.toString(16))
    @colorOff.alpha = 0.8
    @haloColorOff = @colorOff.clone()
    @haloColorOff.alpha = 0.5

    @colorOn = new paper.Color ('#' + @defaultColorOn.toString(16))
    @colorOn.alpha = 0.8
    @haloColorOn = @colorOn.clone()
    @haloColorOn.alpha = 0.5

    @colorLightsOff = new paper.Color ('#fff')
    @haloLightsOff = @colorLightsOff.clone()
    @haloLightsOff.alpha = 0.5

  draw: ->
    @halo = new paper.Path.Circle
      radius : @haloRadius
      fillColor : @haloColorOff
    @view.addChild @halo

    @bulb = new paper.Path.Circle
      radius : @radius
      fillColor : @colorOff
    @view.addChild @bulb

  turnOn: ->
    @bulb.style.fillColor = @colorOn
    @halo.style.fillColor = @haloColorOn
    setTimeout(=>
      @bulb.style.fillColor = @colorOff
      @halo.style.fillColor = @haloColorOff
    , 3000)

  lightsOff: ->
    @bulb.style.fillColor = @colorLightsOff
    @halo.style.fillColor = @haloLightsOff
    @areLightsOff = true

  lightsOn: ->
    @bulb.style.fillColor = @colorOff
    @halo.style.fillColor = @haloColorOff
    @areLightsOff = false

  update: ->
    if !@areLightsOff and Math.random() > 0.999
      @turnOn()
    @follower.update()
    phase = Math.cos(@power+=@freq)+1
    @haloColorOn.alpha = @haloColorOff.alpha = @haloLightsOff.alpha = phase * 0.20 + 0.11
    if @socket
      @socket.update()
    