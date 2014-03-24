class mk.m11s.bulbs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    mk.m11s.bulbs.BulbSocket.symbol = @assets.symbols.bulbs['bulb_socket.svg']
    @colorOff = @settings.palette.lightBlue
    @colorOn = @settings.palette.lightRed
    @bulbs = []
    @addBodyBulbs()
    @addHeadBulb()
    @addRope()

  addBodyBulbs: ->
    parts = @getPartsExcluding ['head', 'torso', 'pelvis']
    for p in parts
      for i in [1..2]
        bulb = new mk.m11s.bulbs.Bulb p, i * 0.33, @colorOff, @colorOn
        @items.push bulb
        @bulbs.push bulb
    
  addHeadBulb: ->
    bulb = new mk.m11s.bulbs.Bulb @getPart('head'), 0, @colorOff, @colorOn
    @items.push bulb
    @bulbs.push bulb

  addRope: ->
    rope = new mk.m11s.bulbs.Rope @getJoints([NiTE.LEFT_HAND, NiTE.RIGHT_HAND]), @settings.palette
    rope.onLightsOff = @onLightsOff
    rope.onLightsOn = @onLightsOn
    @items.push rope

  onLightsOff: =>
    setBackgroundColor '#172828'
    b.lightsOff() for b in @bulbs

  onLightsOn: =>
    setBackgroundColor '#fff'
    b.lightsOn() for b in @bulbs