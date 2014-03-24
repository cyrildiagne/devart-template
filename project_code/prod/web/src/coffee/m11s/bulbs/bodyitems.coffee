class mk.m11s.bulbs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    mk.m11s.bulbs.BulbSocket.symbol = @assets.symbols.bulbs['bulb_socket.svg']
    @colorOff = @settings.palette.lightBlue
    @colorOn = @settings.palette.lightRed
    @addBodyBulbs()
    @addHeadBulb()

  addBodyBulbs: () ->
    parts = @getPartsExcluding ['head', 'torso', 'pelvis']
    for p in parts
      for i in [1..2]
        bulb = new mk.m11s.bulbs.Bulb p, i * 0.33, @colorOff, @colorOn
        @items.push bulb
    
  addHeadBulb: () ->
    bulb = new mk.m11s.bulbs.Bulb @getPart('head'), 0, @colorOff, @colorOn
    @items.push bulb