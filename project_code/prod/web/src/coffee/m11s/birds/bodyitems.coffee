class mk.m11s.birds.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @trees = []
    @treeItems = []
    @timeBetweenNewTreeItem = 3000
    @interval = 0

    @addTree()
    @addTree()
    @addTree()
    @addHouses()
    @addBodyFlowers()

  update : (dt) ->
    super dt
    @interval+=dt*1000
    if @interval >= @timeBetweenNewTreeItem
      @interval -= @timeBetweenNewTreeItem
      @newTreeItemTick()

  addHouses: ->
    symbs = ['house1.svg', 'house2.svg', 'house3.svg', 'house_side1.svg', 'house_side2.svg', 'house_side3.svg']
    parts = @getPartsExcluding ['head', 'pelvis']

    rdmk = 'addHouses'
    for p in parts
      isTorso = p.name is 'torso'
      num = if isTorso then 8 else 2
      scale = rng(rdmk)*(if isTorso then 1 else -0.3) + 1

      for i in [1..num]
        if rng(rdmk) > 0.5
          sname = symbs.seedRandom rdmk
          symbol = @assets.symbols.birds[sname]
          
          item = new mk.m11s.SimplePartItem symbol, p, 'House'
          item.view.scale 0.001
          @items.push item

          do (item) ->
            tween = new TWEEN.Tween({ scale: 0.001 })
             .to({ scale: scale }, 3000)
             .delay(rng(rdmk)*15000 + 1000)
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate(->
                item.view.scaling = new paper.Point(@scale, @scale)
             ).start()

  addTree: ->
    if rng('addTree') > 0.5
      parts = @getParts ['leftLowerLeg', 'leftLowerArm']
      ang = -135
    else
      parts = @getParts ['rightLowerLeg', 'rightLowerArm']
      ang = -45
    p = parts.seedRandom 'addTree'
    tree = new mk.m11s.birds.Branches p.joints[1], p.joints[0], rng('addTree'),
      branchColor       : '#' + p.color.toString(16)
      maxBranches       : Math.floor(rng('addTree')*6) + 3
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
      item = new mk.m11s.SimplePartItem symbol, p, 'Flower'
      item.view.scale 0.001
      @items.push item

      do (item) ->
        tween = new TWEEN.Tween({ scale: 0.001 })
         .to({ scale: 1 }, 3000)
         .delay(rng(rdmk)*15000 + 1000)
         .easing( TWEEN.Easing.Quadratic.Out )
         .onUpdate(->
            item.view.scaling = new paper.Point(@scale, @scale)
         ).start()

  newTreeItemTick: =>
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
       ).start()