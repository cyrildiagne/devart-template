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
    delay 4000, => @addDrawers()
    # @addDrawers()
    @drawersWithItems = []

    @physics = new mk.helpers.Physics()
    @physics.addPersoPartRect @getPart('leftLowerArm')
    @physics.addPersoPartRect @getPart('rightLowerArm')
    @physics.addPersoPartRect @getPart('leftUpperArm')
    @physics.addPersoPartRect @getPart('rightUpperArm')

    @mode = -1
    @buttons = null
    # @addButtons()

    @flys = []
    @availableJoints = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @velTracker = new mk.helpers.JointVelocityTracker @availableJoints

  onMusicEvent : (evId) ->
    console.log evId

  onMusicEvent : (evId) ->
    switch evId
      when 0 
        @mode = 0
        @hintOnOpenedDrawer()
      when 2
        @closeOpenDrawers()
        @mode = -1
      when 3
        @mode = 1
        @hintOnOpenedDrawer 1
      when 7
        @cleanFlyings()
        @mode = 2
        @addButtons()
        break

  hintOnOpenedDrawer: (max=99) ->
    bOneAppeared = false
    num = 0
    for d in @drawers
      if d.isOpen
        bOneAppeared = true
        @drawerOpenedCallback d
        num++
        if num >= max then break
    if !bOneAppeared
      @drawers[0].toggle()

  closeOpenDrawers: ->
    for d in @drawers
      if d.isOpen
        d.toggle()

  addDrawers: ->
    DrawerClass = m11Class 'Drawer'
    ds = ['drawer1', 'drawer2']
    parts = @getParts ['torso', 'pelvis', 'leftUpperLeg', 'rightUpperLeg']
    parts.unshift parts.splice(1,1)[0]
    dl = 0
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
        dl += if dl is 5000 then 12000 else 5000
        do (p, opt, dl) =>
          delay dl, =>
            drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p, opt
            drawer.openCallback = @drawerOpenedCallback
            drawer.closeCallback = @drawerClosingCallback
            @items.push drawer
            @drawers.push drawer
    return

  addButtons: ->
    @buttons = new mk.m11s.tiroirs.Buttons @physics, @assets.symbols.tiroirs

  drawerClosingCallback : (dr) =>
    switch @mode
      when 0
        dr.shrinkItem()
        idx = @drawersWithItems.indexOf dr
        if idx > -1
          @drawersWithItems.splice idx,1

  drawerOpenedCallback : (dr) =>
    switch @mode
      when 0
        if dr.growItem()
          @items.push dr.drawerItem
        @drawersWithItems.push dr
        if @drawersWithItems.length > 3
          oldDr = @drawersWithItems.shift()
          oldDr.toggle()
      when 1
        if @flys.length < 3
          @addFlying dr
      when 2
        for i in [0...4]
          @buttons.buttonsToAdd.push {x:dr.view.position.x, y:dr.view.position.y-10}

  cleanFlyings : ->
    for fly in @flys
      fly.stop()
      if fly.item
        fly.item.remove()
      fly.view.remove()
      @items.splice @items.indexOf(fly.view),1

    @scarf1.view.remove()
    @items.splice @items.indexOf(@scarf1.view),1
    @scarf2.view.remove()
    @items.splice @items.indexOf(@scarf2.view),1
    @flys.splice 0, @flys.length

  addFlying: (drawer) ->
    if @flys.length is 0
      obj = 
        symbol : @assets.symbols.tiroirs['hat']
        pivot : new paper.Point 0, 0
    else if @flys.length is 1
      obj = 
        symbol : @assets.symbols.tiroirs['necktie1']
        pivot : new paper.Point 0, -28
    else
      @addScarf drawer
      return

    item = obj.symbol.place()
    item.pivot = obj.pivot
    fly = new (m11Class 'Flying') item, @flys.length,
      color1 : '#' + @settings.palette.cream.toString 16
      color2 : '#' + @settings.palette.beige.toString 16
      pos : new paper.Point 0,0
      # dest : new paper.Point 0, -400
    fly.view.z = 2000
    
    @flys.push fly
    @items.push fly

    fly.stop()
    fly.view.transformContent = false
    fly.view.scaling = 0.01
    tween = new TWEEN.Tween({scale:0.01}).to({scale:1}, 700)
     .delay(400)
     .easing( TWEEN.Easing.Quadratic.Out )
     .onStart(->
      fly.view.position.x = fly.pos.x = drawer.view.position.x
      fly.view.position.y = fly.pos.y = drawer.view.position.y - 10
      fly.start()
     )
     .onUpdate(->
      fly.view.scaling = @scale
     ).start window.currentTime

  addScarf: (drawer) ->
    fly = new (m11Class 'Flying') null, @flys.length,
      color1 : '#' + @settings.palette.cream.toString 16
      color2 : '#' + @settings.palette.beige.toString 16
      pos : new paper.Point 0,0
    fly.view.z = 1998 #0.5
    @flys.push fly
    @items.push fly
    
    s1 = @scarf1 = new (m11Class 'Scarf') new paper.Point(),
      color     : '#' + @settings.palette.blue.toString(16)
      stiffness : 0.85
    s1.view.z = 1997
    @items.push @scarf1

    j = @joints[NiTE.LEFT_HAND]
    s2 = @scarf2 = new (m11Class 'Scarf') new paper.Point(),
      color     : '#' + @settings.palette.lightBlue.toString(16)
      stiffness : 0.9
      numPoints : 6
    s2.view.z = 1999
    @items.push @scarf2

    fly.stop()
    # fly.view.transformContent = false
    s1.view.scaling = s2.view.scaling = fly.view.scaling = 0.01
    tween = new TWEEN.Tween({scale:0.01}).to({scale:1}, 400)
     .easing( TWEEN.Easing.Quadratic.Out )
     .onStart(->
      # fly.view.position.x = fly.pos.x = drawer.view.position.x
      # fly.view.position.y = fly.pos.y = drawer.view.position.y - 10
      fly.start()
     )
     .onUpdate(->
      s1.view.scaling = s2.view.scaling = fly.view.scaling = @scale
     ).start window.currentTime
  
  updateFlyings : ->
    if @flys.length is 3
      if @flys[2].isFlying
        @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].view.position.x
        @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].view.position.y - 10
      else if @flys[2].joint
        @scarf1.pinPoint.x = @scarf2.pinPoint.x = @flys[2].joint.x
        @scarf1.pinPoint.y = @scarf2.pinPoint.y = @flys[2].joint.y - 10

    for fly in @flys
      if fly.isFlying
        for j,i in @availableJoints
          if j.isUsed then continue
          fp = fly.view.position
          d = (j.x-fp.x) * (j.x-fp.x) + (j.y-fp.y) * (j.y-fp.y)
          if d < 50*50
            fly.joint = j
            fly.stop()
            j.isUsed = true
      else if fly.joint
        fly.view.position.x = fly.joint.x
        fly.view.position.y = fly.joint.y
        if fly.joint is @joints[NiTE.LEFT_HAND]
          vel = @velTracker.get 0
        else
          vel = @velTracker.get 1
        if vel > 180
          fly.start new paper.Point fly.joint.x, fly.joint.y
          jnt = fly.joint
          fly.joint = null
          tween = new TWEEN.Tween({}).to({}, 500)
           .onComplete(->
              jnt.isUsed = false
           ).start window.currentTime
    return

  updateDrawerOpening : ->
    distMax = 20 * 20
    for j in [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
      for dr in @drawers
        dpos = dr.view.position
        dist = (j.x-dpos.x) * (j.x-dpos.x) + (j.y-dpos.y) * (j.y-dpos.y)
        if dist < distMax
          dr.toggle()
    return
  
  update: (dt) ->
    super dt

    if @buttons
      @physics.update dt
      @buttons.update dt
    else if @flys.length
      @velTracker.update()
      @updateFlyings()

    @updateDrawerOpening()
      