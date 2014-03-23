class mk.m11s.tiroirs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @addDrawers()
    @addHat()
    @addScarf()

  addDrawers: ->
    DrawerClass = m11Class 'Drawer'
    ds = ['drawer1.svg', 'drawer2.svg']
    parts = @getParts ['torso', 'pelvis', 'leftUpperLeg', 'rightUpperLeg']
    for p in parts
      for i in [1..3]
        symbol = ds.random()
        drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p
        @items.push drawer
    
  addHat: ->
    HatClass = m11Class 'Hat'
    symbol = @assets.symbols.tiroirs['hat.svg']
    # joints = @getJoints [NiTE.LEFT_HAND, NiTE.RIGHT_HAND]
    # hat = null
    # if Math.random() < 0.5
    #   hat = new HatClass symbol, joints[0], true
    # else 
    #   hat = new HatClass symbol, joints[1]
    hat = new HatClass symbol, @joints[NiTE.RIGHT_HAND]
    @items.push hat

  addScarf: ->

    j = @joints[NiTE.LEFT_HAND]
    scarf = new (m11Class 'Scarf') j,
      color     : '#' + @settings.palette.beige.toString(16)
      stiffness : 0.9
      numPoints : 6
      offset    : new paper.Point(15, 15)
    @items.push scarf

    j = @joints[NiTE.LEFT_HAND]
    scarf = new (m11Class 'Scarf') j,
      color     : '#' + @settings.palette.lightBlue.toString(16)
      stiffness : 0.85
    @items.push scarf