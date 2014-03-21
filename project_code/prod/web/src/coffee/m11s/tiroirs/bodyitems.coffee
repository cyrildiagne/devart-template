class mk.m11s.tiroirs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addDrawers()
    @addHat()

  addDrawers: () ->
    DrawerClass = m11Class 'Drawer'
    ds = ['drawer1.svg', 'drawer2.svg']
    parts = @getParts ['torso', 'pelvis', 'leftUpperLeg', 'rightUpperLeg']
    for p in parts
      for i in [1..3]
        symbol = ds[Math.floor(Math.random()*ds.length)]
        drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p
        @items.push drawer
    
  addHat: () ->
    HatClass = m11Class 'Hat'
    symbol = @assets.symbols.tiroirs['hat.svg']
    joints = @getJoints [NiTE.LEFT_HAND, NiTE.RIGHT_HAND]
    hat = null
    if Math.random() < 0.5
      hat = new HatClass symbol, joints[0], true
    else 
      hat = new HatClass symbol, joints[1]
    @items.push hat