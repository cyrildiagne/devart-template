class mk.m11s.bulbs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    mk.m11s.bulbs.BulbSocket.symbol = @assets.symbols.bulbs['bulb_socket']
    @colorOff = @settings.palette.lightBlue
    @colorOn = @settings.palette.lightRed
    @bulbs = []
    @addBodyBulbs()
    @addHeadBulb()

    @rope = null

    @mode = 0
    @MODE_RAYS = 1
    @MODE_RAYS = 1
    @MODE_CONNECT = 2
    @MODE_LIFT = 3
    @NUM_MODES = 3
    @bLockLight = false
    @lifModeIsDown = false

  clean: ->
    super()
    setBackgroundColor '#black'

  onMusicEvent : (evId) ->
    switch evId
      when 0 
        @addRope()
        break

  update: (dt) ->
    super dt
    switch @mode
      when @MODE_CONNECT
        for b in @bulbs
          b.updateConnections(dt)
          b.connectToNearbyBulbs(@bulbs) 
      when @MODE_RAYS 
        b.updateRedBlink(dt) for b in @bulbs
  
  setupMode: ->
    switch @mode
      when @MODE_CONNECT
        p.view.visible = false for p in @parts
      when @MODE_RAYS
        b.setupRay() for b in @bulbs
      when @MODE_LIFT
        @onLightsOn(false)
        @bLockLight = true
        @lift (@lifModeIsDown=!@lifModeIsDown)
        

  cleanMode: ->
    switch @mode
      when @MODE_CONNECT
        p.view.visible = true for p in @parts
        b.removeConnections() for b in @bulbs
        B = mk.m11s.bulbs.Bulb
        if B::maxConnection is 0 then B::maxConnection += 2
        else B::maxConnection*=2
      when @MODE_RAYS
        b.removeRay() for b in @bulbs
        mk.m11s.bulbs.Bulb::maxRays += 1

  lift: (up=true) ->
    canvas = document.getElementById('paperjs-canvas')
    dst = window.viewport.height
    if !up then dst *= -1

    back = new TWEEN.Tween({y:dst})
    .to({y:0}, 2000)
    .easing( TWEEN.Easing.Quadratic.Out )
    .onUpdate(->
      canvas.style.top = @y+'px'
    )
    .onComplete(=>
      @bLockLight = false
      @onLightsOff()
    )

    tween = new TWEEN.Tween({y:0})
    .to({y:-dst}, 1000)
    .chain(back)
    .easing( TWEEN.Easing.Quadratic.In )
    .onUpdate(->
      canvas.style.top = @y+'px'
    ).start window.currentTime

  addBodyBulbs: ->
    parts = @getPartsExcluding ['head', 'torso', 'pelvis']
    delay = 0
    id = 0
    for p in parts
      for i in [1..2]
        delay++
        do (p,i,delay) =>
          delayed delay*1000, =>
            bulb = new mk.m11s.bulbs.Bulb p, i * 0.33, @colorOff, @colorOn, @bulbs.length
            @items.push bulb
            @bulbs.push bulb
            bulb.id = id++
  
  addHeadBulb: ->
    bulb = new mk.m11s.bulbs.Bulb @getPart('head'), 0, @colorOff, @colorOn, @bulbs.length
    @items.push bulb
    @bulbs.push bulb

  addRope: ->
    @rope = new mk.m11s.bulbs.Rope @getJoints([NiTE.LEFT_HAND, NiTE.RIGHT_HAND]), @settings.palette
    @rope.onLightsOff = @onLightsOn
    @rope.onLightsOn = @onLightsOff
    @items.push @rope

  onLightsOn:(changeMode=true)=>
    if @bLockLight then return

    setBackgroundColor '#fff'
    b.lightsOn() for b in @bulbs

    if changeMode
      @cleanMode()
      @mode++
      if @mode > @NUM_MODES
        @mode = 1
      @setupMode()
      @rope.yoyo()

  onLightsOff: =>

    if @bLockLight then return

    setBackgroundColor 'black'
    b.lightsOff() for b in @bulbs