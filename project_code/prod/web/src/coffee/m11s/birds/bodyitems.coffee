class mk.m11s.birds.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @trees = []
    @treeItems = []
    @interval = setInterval @newTreeItemTick, 3000
    @addTree()
    @addTree()
    @addTree()
    @addHouses()
    @addBodyFlowers()
  
  clean: ->
    super()
    clearInterval @interval

  addHouses: ->
    symbs = ['house1.svg', 'house2.svg', 'house3.svg', 'house_side1.svg', 'house_side2.svg', 'house_side3.svg']
    parts = @getPartsExcluding ['head', 'pelvis']
    for p in parts
      isTorso = p.name is 'torso'
      num = if isTorso then 8 else 2
      scale = Math.random()*(if isTorso then 1 else -0.3) + 1
      for i in [1..num]
        if Math.random() > 0.5
          sname = symbs.random()
          symbol = @assets.symbols.birds[sname]
          
          item = new mk.m11s.SimplePartItem symbol, p
          item.view.scale 0.001
          @items.push item

          do (item) ->
            tween = new TWEEN.Tween({ scale: 0.001 })
             .to({ scale: scale }, 3000)
             .delay(Math.random()*15000 + 1000)
             .easing( TWEEN.Easing.Quadratic.Out )
             .onUpdate(->
                item.view.scaling = new paper.Point(@scale, @scale)
             ).start()

  addTree: ->
    if Math.random() > 0.5
      parts = @getParts ['leftLowerLeg', 'leftLowerArm']
      ang = -135
    else
      parts = @getParts ['rightLowerLeg', 'rightLowerArm']
      ang = -45
    p = parts.random()
    tree = new mk.m11s.birds.Branches p.joints[1], p.joints[0], Math.random(),
      branchColor       : '#' + p.color.toString(16)
      maxBranches       : Math.floor(Math.random()*6) + 3
      maxBranchLength   : Math.random() * 450 + 250
      firstBranchAngles : [ang]
    @items.push tree
    @trees.push tree

  addBodyFlowers: ->
    for i in [0...3]
      p = (@getPartsExcluding ['head', 'pelvis', 'torso']).random()
      symbolName = ['flower1.svg', 'flower2.svg'].random()
      symbol = @assets.symbols.birds[symbolName]
      item = new mk.m11s.SimplePartItem symbol, p
      item.view.scale 0.001
      @items.push item

      do (item) ->
        tween = new TWEEN.Tween({ scale: 0.001 })
         .to({ scale: 1 }, 3000)
         .delay(Math.random()*15000 + 1000)
         .easing( TWEEN.Easing.Quadratic.Out )
         .onUpdate(->
            item.view.scaling = new paper.Point(@scale, @scale)
         ).start()

  newTreeItemTick: =>
    tree = @trees.random()
    if tree.trackPoints.length < tree.branches.length / 2
      symbolName = ['flower1.svg', 'flower2.svg', 'nest1.svg'].random()
      symbol = @assets.symbols.birds[symbolName]
      view = symbol.place()
      view.scale 0.01
      view.transformContent = false
      if symbolName isnt 'nest1.svg'
        view.rotation = Math.random() * 360
      tree.addTrackPoint view

      tween = new TWEEN.Tween( { scale: 0.01 } )
       .to( { scale: 1 }, 3000 )
       .easing( TWEEN.Easing.Elastic.Out )
       .onUpdate( ->
          view.scaling = new paper.Point(@scale, @scale)
       ).start()