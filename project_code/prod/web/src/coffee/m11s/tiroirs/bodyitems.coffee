class mk.m11s.tiroirs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @flys = []
    @addDrawers()
    @setupFlyings()
    @addScarf()
    @availableJoints = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @count = 0

  addDrawers: ->
    DrawerClass = m11Class 'Drawer'
    ds = ['drawer1.svg', 'drawer2.svg']
    parts = @getParts ['torso', 'pelvis', 'leftUpperLeg', 'rightUpperLeg']
    for p in parts
      for i in [1..3]
        symbol = ds.random()
        drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p
        @items.push drawer
    
  setupFlyings: ->
    color = '#' + @settings.palette.cream.toString 16
    color2 = '#' + @settings.palette.beige.toString 16
    hat = 
      symbol : @assets.symbols.tiroirs['hat.svg']
      pivot : new paper.Point 0, 0

    necktie = 
      symbol : @assets.symbols.tiroirs['necktie1.svg']
      pivot : new paper.Point 0, -28

    symbols = [hat, necktie]
    for s in symbols
      item = s.symbol.place()
      item.pivot = s.pivot
      fly = new (m11Class 'Flying') item, color2, color
      @flys.push fly
      @items.push fly

  addScarf: ->
    color = '#' + @settings.palette.cream.toString 16
    color2 = '#' + @settings.palette.beige.toString 16
    fly = new (m11Class 'Flying') null, color2, color
    fly.view.z = 0.5
    @flys.push fly
    @items.push fly
    
    @scarf1 = new (m11Class 'Scarf') new paper.Point(),
      color     : '#' + @settings.palette.blue.toString(16)
      stiffness : 0.85
    @items.push @scarf1

    j = @joints[NiTE.LEFT_HAND]
    @scarf2 = new (m11Class 'Scarf') new paper.Point(),
      color     : '#' + @settings.palette.lightBlue.toString(16)
      stiffness : 0.9
      numPoints : 6
    @scarf2.view.z = 1
    @items.push @scarf2
  
  update: ->
    super()

    if @flys[2].isFlying
      @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].view.position.x
      @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].view.position.y - 10
    else
      @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].joint.x
      @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].joint.y - 10
    
    if(@count++ < 50) then return

    for fly in @flys
      if fly.isFlying
        for j,i in @availableJoints
          if j.isUsed then continue
          fp = fly.view.position
          d = (j.x-fp.x) * (j.x-fp.x) + (j.y-fp.y) * (j.y-fp.y)
          if d < 25*25
            fly.joint = j
            fly.stop()
            j.isUsed = true
      else
        fly.view.position.x = fly.joint.x
        fly.view.position.y = fly.joint.y