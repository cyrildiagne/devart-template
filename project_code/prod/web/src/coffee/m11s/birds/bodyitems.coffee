class mk.m11s.birds.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addTree()
    @addTree()
    @addTree()
    @addHouses()
    
  addHouses: () ->
    symbs = ['house1.svg', 'house2.svg', 'house3.svg', 'house_side1.svg', 'house_side2.svg', 'house_side3.svg']
    parts = @getPartsExcluding ['head', 'pelvis']
    for p in parts
      isTorso = p.name is 'torso'
      num = if isTorso then 10 else 2
      scale = Math.random()*(if isTorso then 1 else -0.3) + 1
      for i in [1..num]
        if Math.random() > 0.5
          sname = symbs[Math.floor(Math.random()*symbs.length)]
          symbol = @assets.symbols.birds[sname]
          item = new mk.m11s.SimplePartItem symbol, p
          item.view.scale scale
          @items.push item

  addTree: () ->
    if Math.random() > 0.5
      parts = @getParts ['leftLowerLeg', 'leftLowerArm']
      ang = -135
    else
      parts = @getParts ['rightLowerLeg', 'rightLowerArm']
      ang = -45
    p = parts[ Math.floor(Math.random()*parts.length) ]
    tree = new mk.m11s.birds.Branches p.joints[1], p.joints[0], Math.random(),
      branchColor       : '#' + p.color.toString(16)
      maxBranches       : Math.floor(Math.random()*6) + 3
      maxBranchLength   : Math.random() * 600 + 250
      firstBranchAngles : [ang]
    @items.push tree