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
    delayed 4000, => @addDrawers()
    # @addDrawers()
    @drawersWithItems = []

    @mode = -1
    @physics = null
    @buttons = null
    # @addButtons()

    @flys = []
    @flyLock = false
    @availableJoints = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @velTracker = new mk.helpers.JointVelocityTracker @availableJoints

  onMusicEvent : (evId) ->
    console.log evId

  onMusicEvent : (evId) ->
    switch evId
      when 0 
        @mode = 0
        @ensureDrawersOpen()
      when 2
        @mode = -1
        @closeOpenDrawers()
        @cleanDrawerItems()
      when 3
        @mode = 1
        @ensureDrawersOpen 1
      when 7
        @cleanFlyings()
        @mode = 2
        @addButtons()
      when 9
        d.growToInfinity() for d in @drawers
        break

  cleanDrawerItems: ->
    for d in @drawers
      do (d) =>
        d.shrinkItem true, =>
          idx = @items.indexOf(d.drawerItem)
          if idx > -1
            @items.splice idx,1
    @drawersWithItems.splice 0,@drawersWithItems.length

  ensureDrawersOpen: (max=99) ->
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
          delayed dl, =>
            drawer = new DrawerClass @assets.symbols.tiroirs[symbol], p, opt
            drawer.items = @items
            drawer.openCallback = @drawerOpenedCallback
            drawer.closeCallback = @drawerClosingCallback
            @items.push drawer
            @drawers.push drawer
    return

  addButtons: ->
    @physics = new mk.helpers.Physics()
    @physics.addPersoPartRect @getPart('leftLowerArm')
    @physics.addPersoPartRect @getPart('rightLowerArm')
    @physics.addPersoPartRect @getPart('leftUpperArm')
    @physics.addPersoPartRect @getPart('rightUpperArm')
    @buttons = new mk.m11s.tiroirs.Buttons @physics, @assets.symbols.tiroirs

  drawerClosingCallback : (dr) =>
    switch @mode
      when 0, -1
        dr.shrinkItem()
        idx = @drawersWithItems.indexOf dr
        if idx > -1
          @drawersWithItems.splice idx,1

  drawerOpenedCallback : (dr) =>
    switch @mode
      when 0
        dr.growItem()
        #if dr.growItem()
        #@items.push dr.drawerItem
        @drawersWithItems.push dr
        if @drawersWithItems.length > 3
          oldDr = @drawersWithItems.shift()
          oldDr.toggle()
      when 1
        if @flyLock then return
        for fly in @flys
          if !fly.bFlyingToDrawer 
            otherDr = @drawers.random()
            if !otherDr.isOpen then otherDr.toggle(true)
            @removeFlying fly, otherDr
        # if @flys.length < 3
        @addFlying dr
      when 2
        for i in [0...4]
          @buttons.buttonsToAdd.push {x:dr.view.position.x, y:dr.view.position.y-10}

  addFlying: (drawer) ->

    if @flyLock then return
    @flyLock = true
    delayed 2000, => @flyLock = false

    switch rngi('aflg',1,3)
      when 1
        obj = 
          symbol : @assets.symbols.tiroirs['hat']
          pivot : new paper.Point 0, 0
      when 2
        obj = 
          symbol : @assets.symbols.tiroirs['necktie1']
          pivot : new paper.Point 0, -28
      when 3
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

    fly.grabLocked = true
    delayed 1000, -> fly.grabLocked = false

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
    
    fly.scarf = new mk.m11s.tiroirs.Scarf()

    fly.stop()
    s1 = fly.scarf.scarf1
    s2 = fly.scarf.scarf2
    s1.view.scaling = s2.view.scaling = fly.view.scaling = 0.01
    tween = new TWEEN.Tween({scale:0.01}).to({scale:1}, 400)
     .easing( TWEEN.Easing.Quadratic.Out )
     .onStart(->
      fly.start()
     )
     .onUpdate(->
      s1.view.scaling = s2.view.scaling = fly.view.scaling = @scale
     ).start window.currentTime

  removeFlying : (fly, drawer) ->
    fly.flyToDrawer drawer, => 
      fly.joint.isUsed = false if fly.joint
      if drawer.isOpen then drawer.toggle()
      delayed 1, => @cleanFlying fly

  cleanFlyings : ->
    @removeFlying(fly, @drawers.random()) for fly in @flys
  
  cleanFlying : (fly) ->
    fly.stop()
    if fly.scarf
      fly.scarf.clean()
    if fly.item
      fly.item.remove()
    fly.view.remove()
    @items.splice @items.indexOf(fly),1
    @flys.splice @flys.indexOf(fly),1

  updateFlyings : ->

    for fly in @flys

      if fly.isFlying and fly.scarf
        fly.scarf.update fly.view.position # scarf

      continue if fly.bFlyingToDrawer

      if fly.isFlying
        
        if fly.grabLocked then continue

        for j,i in @availableJoints
          if j.isUsed then continue
          fp = fly.view.position
          d = (j.x-fp.x) * (j.x-fp.x) + (j.y-fp.y) * (j.y-fp.y)
          if d < 60*60
            fly.joint = j
            fly.stop()
            j.isUsed = true

      else if fly.joint

        if fly.scarf then fly.scarf.update fly.joint # scarf
        fly.view.position.x = fly.joint.x
        fly.view.position.y = fly.joint.y
        # if fly.joint is @joints[NiTE.LEFT_HAND]
        #   vel = @velTracker.get 0
        # else
        #   vel = @velTracker.get 1
        # if vel > 180
        #   fly.start new paper.Point fly.joint.x, fly.joint.y
        #   jnt = fly.joint
        #   fly.joint = null
        #   tween = new TWEEN.Tween({}).to({}, 500)
        #    .onComplete(->
        #       jnt.isUsed = false
        #    ).start window.currentTime
    return

  updateDrawerOpening : ->
    distMax = 30 * 30
    for j in [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
      if j.isUsed then continue
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
      