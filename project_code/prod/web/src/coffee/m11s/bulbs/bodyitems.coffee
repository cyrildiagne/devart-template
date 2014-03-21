class mk.m11s.bulbs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addBodyBulbs()
    @addHeadBulb()

  addBodyBulbs: () ->
    symbs = ['bulb1.svg', 'bulb2.svg', 'bulb3.svg']
    parts = @getPartsExcluding ['head', 'torso', 'pelvis']
    for p in parts
      for i in [1..3]
        if Math.random() > 0.6
          sname = symbs[Math.floor(Math.random()*symbs.length)]
          symbol = @assets.symbols.bulbs[sname]
          bulb = new mk.m11s.SimplePartItem symbol, p
          bulb.view.scale Math.random()*0.8 + 1
          bulb.view.rotation = Math.random() * 360
          @items.push bulb
    
  addHeadBulb: () ->
    symbol = @assets.symbols.bulbs['bulb1.svg']
    bulb = new mk.m11s.SimpleJointItem symbol, @joints[NiTE.HEAD]
    bulb.view.scale 1.5
    @items.push bulb