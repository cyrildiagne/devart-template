class mk.m11s.tiroirs.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @drawerPos =
      torso : [
        { weights : [0.0, 0.25, 0.75], scale : 0.4, z: 55 }
        { weights : [0.15, 0.65, 0.2], scale : 0.4, z: 50 }
        { weights : [0.28, 0.16, 0.56], scale : 0.4, z: 45 }
        { weights : [0.42, 0.45, 0.13], scale : 0.4, z: 40 }
        { weights : [0.6, 0.2, 0.2], scale : 0.6, z: 35 }
        { weights : [0.8, 0.1, 0.1], scale : 0.5, z: 30 }
      ]
      pelvis : [
       { weights : [0.4, 0.3, 0.3], scale : 0.4, z: 25 } 
      ]
      leftUpperLeg : [
       { weights : [0.2, 0.8], scale : 0.2, z: 20 } 
       { weights : [0.4, 0.6], scale : 0.2, z: 15 } 
       { weights : [0.6, 0.4], scale : 0.2, z: 10 } 
       { weights : [0.8, 0.2], scale : 0.2, z: 5 } 
      ]
      rightUpperLeg : [
       { weights : [0.2, 0.8], scale : 0.2, z: 20 } 
       { weights : [0.4, 0.6], scale : 0.2, z: 15 } 
       { weights : [0.6, 0.4], scale : 0.2, z: 10 } 
       { weights : [0.8, 0.2], scale : 0.2, z: 5 } 
      ]
    @drawers = []
    @addDrawers()

    @physics = new mk.helpers.Physics()
    @addPersoPartRectCount = 0
    @physics.addPersoPartRect @getPart('leftLowerArm')
    @physics.addPersoPartRect @getPart('rightLowerArm')
    @physics.addPersoPartRect @getPart('leftUpperArm')
    @physics.addPersoPartRect @getPart('rightUpperArm')

    @buttons = null
    @addButtons()

    @flys = []
    # @setupFlyings()
    # @addScarf()
    @availableJoints = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]

  onMusicEvent : (evId) ->
    console.log evId

  addDrawers: ->
    DrawerClass = m11Class 'Drawer'
    ds = ['drawer1.svg', 'drawer2.svg']
    parts = @getParts ['torso', 'pelvis', 'leftUpperLeg', 'rightUpperLeg']
    for p in parts
      max = 2
      switch p.name
        when 'pelvis' then max = 1
        when 'torso' then max = @drawerPos['torso'].length
      for i in [1..max]
        symbol = ds.seedRandom 'addDrawers'
        opts = @drawerPos[p.name]
        id = Math.floor(rng('addDrawer')*opts.length)
        opt = opts.splice(id, 1)[0]
        drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p, @settings, opt
        @items.push drawer
        @drawers.push drawer

  addButtons: ->
    @buttons = new mk.m11s.tiroirs.Buttons @physics, @assets.symbols.tiroirs

  setupFlyings: ->
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
      fly = new (m11Class 'Flying') item, @flys.length,
        color1 : '#' + @settings.palette.cream.toString 16
        color2 : '#' + @settings.palette.beige.toString 16
      @flys.push fly
      @items.push fly

  addScarf: ->
    fly = new (m11Class 'Flying') null, @flys.length,
      color1 : '#' + @settings.palette.cream.toString 16
      color2 : '#' + @settings.palette.beige.toString 16
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
  
  updateFlyings : ->
    if @flys[2].isFlying
      @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].view.position.x
      @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].view.position.y - 10
    else
      @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].joint.x
      @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].joint.y - 10

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

  updateDrawerOpening : ->
    distMax = 20 * 20
    for j in [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
      for dr in @drawers
        dpos = dr.view.position
        dist = (j.x-dpos.x) * (j.x-dpos.x) + (j.y-dpos.y) * (j.y-dpos.y)
        if dist < distMax
          if dr.toggle()
            if dr.isOpen
              for i in [0...4]
                @buttons.buttonsToAdd.push {x:dpos.x, y:dpos.y-10}
  
  update: (dt) ->
    super dt

    @physics.update dt

    @buttons.update dt

    @updateDrawerOpening()

    if @flys.length
      @updateFlyings()
      