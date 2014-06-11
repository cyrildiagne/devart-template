class mk.m11s.bulbs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    mk.m11s.bulbs.BulbSocket.symbol = @assets.symbols.bulbs['bulb_socket']
    @colorOff = @settings.palette.lightBlue
    @colorOn = @settings.palette.lightRed
    @bulbs = []
    @addBodyBulbs()
    @addHeadBulb()

    @mode = 0
    @MODE_RED_BLINK = 1
    @MODE_CONNECT = 2
    @MODE_RAYS = 3
    @NUM_MODES = 3
    # delayed 6000, => @addRope()

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
      when @MODE_RED_BLINK 
        b.updateRedBlink(dt) for b in @bulbs
      when @MODE_CONNECT
        for b in @bulbs
          b.updateConnections(dt)
          b.connectToNearbyBulbs(@bulbs) 
          # b.connectToRandomBulbs(@bulbs)
      when @MODE_RAYS 
        b.updateRedBlink(dt) for b in @bulbs
  
  setupMode: ->
    switch @mode
      when @MODE_RAYS
        b.setupRay() for b in @bulbs

  cleanMode: ->
    switch @mode
      when @MODE_RED_BLINK 
        b.stopRedBlink() for b in @bulbs
      when @MODE_CONNECT
        b.removeConnections() for b in @bulbs
      when @MODE_RAYS
        b.removeRay() for b in @bulbs

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
    rope = new mk.m11s.bulbs.Rope @getJoints([NiTE.LEFT_HAND, NiTE.RIGHT_HAND]), @settings.palette
    rope.onLightsOff = @onLightsOn
    rope.onLightsOn = @onLightsOff
    @items.push rope

  onLightsOn: =>
    setBackgroundColor '#fff'
    # @getPart('torso').setColor 0xffffff
    # @getPart('pelvis').setColor 0xffffff
    b.lightsOn() for b in @bulbs

    @cleanMode()
    m = @mode
    while @mode is m
      @mode = 1 + Math.floor(Math.random()*(@NUM_MODES))
    # @mode = @MODE_RAYS
    @setupMode()
    # console.log 'mode is ' + @mode

  onLightsOff: =>
    setBackgroundColor 'black'#'#172828'
    # @getPart('torso').setColor @settings.palette.lightBlue
    # @getPart('pelvis').setColor @settings.palette.lightBlue
    b.lightsOff() for b in @bulbs
    # @mode = 0
    # console.log 'mode is ' + @mode