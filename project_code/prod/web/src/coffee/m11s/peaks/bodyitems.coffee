class mk.m11s.peaks.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addBodyPeaks()
    @addHeadPeak()
    @addFlowers()

  addBodyPeaks: () ->
    symbs = ['peak1.svg', 'peak2.svg']
    parts = @getPartsExcluding ['head']
    rngk = 'addBodyPeaks'
    for p in parts
      for i in [1..3]
        if rng(rngk) > 0.3
          symbol = @assets.symbols.peaks[symbs.seedRandom(rngk)]
          item = new mk.m11s.SimplePartItem symbol, p, 'Peak'+@items.length
          item.view.scale rng(rngk)*0.3 + 1
          item.view.rotation = Math.floor(rng(rngk)*2) * 180
          @items.push item
    
  addHeadPeak: () ->
    symbol = @assets.symbols.peaks['head.svg']
    item = new mk.m11s.SimpleJointItem symbol, @joints[NiTE.HEAD]
    item.view.scale 1.5
    @items.push item

  addFlowers: () ->
    symbs = ['flower1.svg', 'flower2.svg', 'flower3.svg']
    parts = @getParts ['leftLowerLeg', 'rightLowerArm', 'leftUpperArm', 'leftLowerArm', 'rightUpperArm', 'rightLowerArm' ]
    rngk = 'addBodyPeaks'
    for p in parts
      if rng(rngk) > 0.5
        symbol = @assets.symbols.peaks[symbs.seedRandom(rngk)]
        item = new mk.m11s.SimplePartItem symbol, p, 'Flower'
        # item.view.scale Math.random()*0.8 + 1
        item.view.rotation = Math.floor(rng(rngk)*2) * 180
        @items.push item