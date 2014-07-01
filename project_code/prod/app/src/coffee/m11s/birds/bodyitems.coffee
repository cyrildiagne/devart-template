class mk.m11s.birds.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @trees = []
    @treeItems = []

    @bTreeGrowsItems = false
    @timeBetweenNewTreeItem = 625 * 3
    @intervalTreeItem = 0

    # @bGrowTrees = false
    # @timeBetweenNewTree = 625 * 7 * 3
    # @intervalTree = 0

    @bodyFlowers = []
    @treeItems = []

    @houses = []
    delayed 2000, => @addHouses()

    @birds = []

    @moon = null

    @lucioles = null
    @hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]

    if Config::DEBUG
      mouseDownCallbacks.push =>
        t.bShrink = true for t in @trees
      mouseUpCallbacks.push =>
        t.bShrink = false for t in @trees

    # @bGrowHouses = false
    # @timeBetweenNewHouse = 625 * 4
    # @intervalHouse = 0
    # @fadeToColor @settings.palette.blue

  update : (dt) ->
    super dt
    b.update(dt) for b in @birds
    if @bTreeGrowsItems 
      @intervalTreeItem+=dt
      if @intervalTreeItem >= @timeBetweenNewTreeItem
        @intervalTreeItem -= @timeBetweenNewTreeItem
        @newTreeItemTick()
    if @moon
      @moon.position.x += (-@joints[NiTE.HEAD].x*0.8-@moon.position.x) * 0.001 * dt
    @checkBirdTouch()
    return

  onMusicEvent : (evId) ->
    switch evId
      when 0 # apparition branches
        # @bGrowTrees = true
        @addTree()
        @addTree()
        @addTree()
        @addTree()
        @addBackLight()
      when 1 # apparition fleurs/feuilles
        @bTreeGrowsItems = true
        @newTreeItemTick()
        @addBodyFlowers()
        # break
      # when 2 # apparition des oiseaux
        times = [625, 625*17, 625*35]
        for duration in times
          tween = new TWEEN.Tween().to({}, duration)
           .onComplete(=>
              @newTreeItemTick 'nest1'
           ).start window.currentTime
      when 3 # oiseaux in/out maisons
        # @bGrowTrees = false
        break
      when 4 # oiseaux in/out maisons
        @removeBackLight()
        h.bReleaseBirds = false for h in @houses
        @setNightMode()
      when 5 # apparition lucioles
        @addLucioles()
      when 7
        @lucioles.addRightHand()
      when 8
        @lucioles.leave()
        @removeMoon()
      when 9
        fadeScene 'off', 7000
        break

  addBackLight : ->
    @backlight = new mk.m11s.birds.BackLight @joints[NiTE.LEFT_FOOT], @joints[NiTE.RIGHT_FOOT]
    @backlight.show() 
    @items.push @backlight

  removeBackLight : ->
    @backlight.hide =>
      @backlight.clean()
      @items.splice @items.indexOf(@backlight),1

  checkBirdTouch : ->
    distMax = 30 * 30
    for j in @hands
      for b in @birds
        if !b.isFlying
          dpos = b.view.position
          dist = (j.x-dpos.x) * (j.x-dpos.x) + (j.y-dpos.y) * (j.y-dpos.y)
          if dist < distMax
            do (b) ->
              b.flyOut ->
                b.flyToBranch b.target
    return


  setNightMode : ->
    color = mk.Scene::settings.getHexColor 'blue'
    i = 0
    for p in @parts
      i++
      p.color = color
      # p.path.fillColor = color
      @fadeToColor p.path, color, 500, 0
      for j in p.jointViews
        # j.view.fillColor = color
        @fadeToColor j.view, color, 500, 0
    @setNightHouses()
    @sendBirdsToHouses()
    @removeTreeItems()
    @removeBodyFlowers()
    @addMoon()
    for t in @trees
      for b in t.branches
        b.path.strokeColor = color
    return null

  addMoon : ->
    hex = '#' + @settings.palette.lightBlue.toString 16

    @moon = new paper.Path.Circle
      position : new paper.Point 100,-1000
      radius : 250
    @moon.fillColor = hex
    @moon.sendToBack()

    brightness = new paper.Color(hex).convert('hsb').brightness

    m = @moon
    tween = new TWEEN.Tween({ y: -1000})
     .to({ y: -350 }, 20000)
     .easing( TWEEN.Easing.Quadratic.Out )
     .onUpdate(->
        m.position.y = @y
     ).start window.currentTime

  removeMoon : ->
    m = @moon
    tween = new TWEEN.Tween({ y: @moon.position.y})
     .to({ y: -1000 }, 18000)
     .easing( TWEEN.Easing.Quadratic.In )
     .onUpdate(->
        m.position.y = @y
     ).start window.currentTime


  fadeToColor : (item, color, duration=1000, delay=0) ->
    # hexa = '#' + color.toString 16
    hsb = new paper.Color(color).convert('hsb')
    tween = new TWEEN.Tween(
      h: item.fillColor.hue
      s: item.fillColor.saturation
      b: item.fillColor.brightness
     )
     .to({ h: hsb.hue, s: hsb.saturation, b: hsb.brightness }, duration)
     .easing( TWEEN.Easing.Linear.None )
     .delay( delay )
     .onUpdate(->
        item.fillColor.hue        = @h
        item.fillColor.saturation = @s
        item.fillColor.brightness = @b
     ).start window.currentTime

  addLucioles : ()->
    leftHand = @joints[NiTE.LEFT_HAND]
    rightHand = @joints[NiTE.RIGHT_HAND]
    @lucioles = new mk.m11s.birds.Lucioles @assets.symbols.birds['luciole'], leftHand, rightHand
    @items.push @lucioles

  addBird : (tree, trackPoint)->
    symbs = ['bird1', 'bird2']
    rdmk = 'addBird'
    sname = symbs.seedRandom rdmk
    symbol = @assets.symbols.birds[sname].place()
    color = if sname is 'bird2' then 'lightRed' else 'blue'
    color = '#' + @settings.palette[color].toString 16
    bird = new mk.m11s.birds.Bird symbol, @items.length, color
    if !tree
      tree = @trees.seedRandom 'addBird'
    # console.log 'addbird'
    bird.flyToBranch trackPoint#tree.addTrackPoint()
    # @items.push bird
    @birds.push bird

  sendBirdsToHouses : ->
    for b in @birds
      house = @houses.seedRandom 'sbth'
      do (b) =>
        b.flyToHouse house, =>
          b.hide()
          delayed 1, =>
            @birds.splice @birds.indexOf(b),1
            # @items.splice @items.indexOf(b),1

  addHouses: ->
    symbs = ['house1', 'house2', 'house3', 'house_side1', 'house_side2', 'house_side3']
    parts = @getPartsExcluding ['head', 'pelvis', 'leftLowerArm', 'rightLowerArm']

    numHouse = 0
    rdmk = 'addHouses'
    # birdWingColor = '#' + @settings.palette.cream.toString 16
    hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    for p in parts
      isTorso = p.name is 'torso'
      num = if isTorso then 6 else 2
      scale = rng(rdmk)*(if isTorso then 1 else -0.3) + 1
      for i in [1..num]
        if rng(rdmk) > 0.5
          sname = symbs.seedRandom rdmk
          house = new mk.m11s.birds.House sname, p, hands
          house.show scale, numHouse++
          @items.push house
          @houses.push house
    return null

  setNightHouses: ->
    delay = 0
    @houses.sort (a, b) ->
      return (if a.view.position.y < b.view.position.y then 1 else -1)
    for h in @houses
      h.setNight (delay++)*500

  addTree: ->
    if rng('addTree') > 0.5
      parts = @getParts ['leftLowerLeg', 'leftLowerArm']
      ang = -135
    else
      parts = @getParts ['rightLowerLeg', 'rightLowerArm']
      ang = -45
    p = parts.seedRandom 'addTree'
    if p.hasTree
      @addTree()
      return
    p.hasTree = true
    opt =
      branchColor       : p.color
      maxBranches       : Math.floor(rng('addTree')*4) + 5
      maxBranchLength   : rng('addTree') * 450 + 250
      firstBranchAngles : [ang]
    if p.name is 'leftLowerLeg' or p.name is 'leftUpperLeg' or p.name is 'rightLowerLeg' or p.name is 'rightUpperLeg'
      opt.velMinForShrink = 150
    tree = new mk.m11s.birds.Branches p.joints[1], p.joints[0], rng('addTree'), opt
    @items.push tree
    @trees.push tree
    # delayed rng('adtr')*500, -> mk.Scene::sfx.play 'branch2'
    return null

  addBodyFlowers: ->
    rdmk = 'addBodyFlowers'
    for i in [0...3]
      p = (@getPartsExcluding ['head', 'pelvis', 'torso']).seedRandom rdmk
      symbolName = ['flower1', 'flower2'].seedRandom rdmk
      symbol = @assets.symbols.birds[symbolName]
      item = new mk.helpers.SimplePartItem symbol, p, 'Flower'
      item.view.scale 0.001
      @items.push item
      @bodyFlowers.push item

      do (item) ->
        rdm = rng(rdmk)*8000
        tween = new TWEEN.Tween({ scale: 0.001 })
         .to({ scale: 1 }, 3000)
         .delay(Math.round(rdm/625)*625)
         .easing( TWEEN.Easing.Quadratic.Out )
         .onUpdate(->
            item.view.scaling = new paper.Point(@scale, @scale)
         ).start window.currentTime
    return null

  removeBodyFlowers : ->
    delay = 0
    items = @items
    for item in @bodyFlowers
      delay+=300
      do (item) ->
        tween = new TWEEN.Tween({scale:1}).to({scale:0}, 500)
         .delay(delay)
         .onUpdate(->
            item.view.scaling = @scale
         )
         .onComplete(->
            item.view.remove()
            items.splice items.indexOf(item), 1
         ).start window.currentTime
    return

  removeTreeItems : ->
    delay = 0
    items = @items
    for item in @treeItems
      delay+=300
      do (item) ->
        tween = new TWEEN.Tween({scale:1}).to({scale:0}, 500)
         .delay(delay)
         .onUpdate(->
          item.scaling = @scale
         )
         .onComplete(->
          # items.splice items.indexOf(item),1
          item.remove()
         ).start window.currentTime
    return

  newTreeItemTick: (symbolName) =>
    if !@bTreeGrowsItems then return
    rdmk = 'newTreeItemTick'
    tree = @trees.seedRandom rdmk
    if symbolName is undefined && tree.trackPoints.length >= tree.branches.length / 2
      return
    # console.log '> doing it'
    symbolName = symbolName || ['flower1', 'flower2'].seedRandom rdmk
    symbol = @assets.symbols.birds[symbolName]
    view = symbol.place()
    view.transformContent = false
    tp = tree.addTrackPoint view
    if symbolName isnt 'nest1'
      view.rotation = rng(rdmk) * 360
    else
      @addBird tree, tp
    @treeItems.push view
    
    # tween = new TWEEN.Tween( { scale: 0.01 } )
    #  .to( { scale: 1 }, 3000 )
    #  .easing( TWEEN.Easing.Elastic.Out )
    #  .onUpdate( ->
    #     view.scaling = new paper.Point(@scale, @scale)
    #  ).start window.currentTime