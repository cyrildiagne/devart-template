class mk.m11s.birds.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @trees = []
    @treeItems = []

    @bTreeGrowsItems = false
    @timeBetweenNewTreeItem = 625 * 3
    @intervalTreeItem = 0

    @bGrowTrees = false
    @timeBetweenNewTree = 625 * 7 * 3
    @intervalTree = 0

    # @bGrowHouses = false
    # @timeBetweenNewHouse = 625 * 4
    # @intervalHouse = 0

    # @addTree()
    # @addTree()
    # @addTree()
    # @addHouses()
    # @addBodyFlowers()

  update : (dt) ->
    super dt
    if @bGrowTrees
      @intervalTree+=dt
      if @intervalTree >= @timeBetweenNewTree
        @intervalTree -= @timeBetweenNewTree
        @addTree()
    if @bTreeGrowsItems 
      @intervalTreeItem+=dt
      if @intervalTreeItem >= @timeBetweenNewTreeItem
        @intervalTreeItem -= @timeBetweenNewTreeItem
        @newTreeItemTick()

  onMusicEvent : (evId) ->
    console.log evId
    # @bGrowTrees = false
    switch evId
      when 0
        @bGrowTrees = true
        @addTree()
      when 1
        @bTreeGrowsItems = true
        @newTreeItemTick()
        @addBodyFlowers()
      when 2
        # @bGrowHouses = true
        @addHouse()
      when 3
        @bGrowTrees = false

  addHouse: ->
    symbs = ['house1.svg', 'house2.svg', 'house3.svg', 'house_side1.svg', 'house_side2.svg', 'house_side3.svg']
    parts = @getPartsExcluding ['head', 'pelvis']

    numHouse = 0
    rdmk = 'addHouses'
    for p in parts
      isTorso = p.name is 'torso'
      num = if isTorso then 8 else 2
      scale = rng(rdmk)*(if isTorso then 1 else -0.3) + 1

      for i in [1..num]
        if rng(rdmk) > 0.5
          sname = symbs.seedRandom rdmk
          symbol = @assets.symbols.birds[sname]
          
          item = new mk.helpers.SimplePartItem symbol, p, 'House'
          item.view.scale 0.01
          @items.push item

          do (item) ->
            rdm = rng(rdmk+'HouseDelay') * 15
            tween = new TWEEN.Tween({ scale: 0.01 })
             .to({ scale: scale }, 1000)
             .delay((numHouse++)*(2650))
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate(->
                item.view.scaling = new paper.Point(@scale, @scale)
             ).start window.currentTime

  addTree: ->
    console.log 'addtree'
    if rng('addTree') > 0.5
      parts = @getParts ['leftLowerLeg', 'leftLowerArm']
      ang = -135
    else
      parts = @getParts ['rightLowerLeg', 'rightLowerArm']
      ang = -45
    p = parts.seedRandom 'addTree'
    tree = new mk.m11s.birds.Branches p.joints[1], p.joints[0], rng('addTree'),
      branchColor       : '#' + p.color.toString(16)
      # maxBranches       : Math.floor(rng('addTree')*4) + 4
      maxBranchLength   : rng('addTree') * 450 + 250
      firstBranchAngles : [ang]
    @items.push tree
    @trees.push tree

  addBodyFlowers: ->
    rdmk = 'addBodyFlowers'
    for i in [0...3]
      p = (@getPartsExcluding ['head', 'pelvis', 'torso']).seedRandom rdmk
      symbolName = ['flower1.svg', 'flower2.svg'].seedRandom rdmk
      symbol = @assets.symbols.birds[symbolName]
      item = new mk.helpers.SimplePartItem symbol, p, 'Flower'
      item.view.scale 0.001
      @items.push item

      do (item) ->
        rdm = rng(rdmk)*8000
        tween = new TWEEN.Tween({ scale: 0.001 })
         .to({ scale: 1 }, 3000)
         .delay(Math.round(rdm/625)*625)
         .easing( TWEEN.Easing.Quadratic.Out )
         .onUpdate(->
            item.view.scaling = new paper.Point(@scale, @scale)
         ).start window.currentTime

  newTreeItemTick: =>
    if !@bTreeGrowsItems then return
    rdmk = 'newTreeItemTick'
    tree = @trees.seedRandom rdmk
    if tree.trackPoints.length < tree.branches.length / 2
      symbolName = ['flower1.svg', 'flower2.svg', 'nest1.svg'].seedRandom rdmk
      symbol = @assets.symbols.birds[symbolName]
      view = symbol.place()
      view.scale 0.01
      view.transformContent = false
      if symbolName isnt 'nest1.svg'
        view.rotation = rng(rdmk) * 360
      tree.addTrackPoint view
      
      tween = new TWEEN.Tween( { scale: 0.01 } )
       .to( { scale: 1 }, 3000 )
       .easing( TWEEN.Easing.Elastic.Out )
       .onUpdate( ->
          view.scaling = new paper.Point(@scale, @scale)
       ).start window.currentTime