class mk.m11s.peaks.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addBodyPeaks()
    @addHeadPeak()
    @addFlowers()

  addBodyPeaks: () ->
    symbs = ['peak1.svg', 'peak2.svg']
    parts = @getPartsExcluding ['head']
    for p in parts
      for i in [1..3]
        if Math.random() > 0.3
          sname = symbs[Math.floor(Math.random()*symbs.length)]
          symbol = @assets.symbols.peaks[sname]
          item = new mk.m11s.SimplePartItem symbol, p
          item.view.scale Math.random()*0.3 + 1
          item.view.rotation = Math.floor(Math.random()*2) * 180
          @items.push item
    
  addHeadPeak: () ->
    symbol = @assets.symbols.peaks['head.svg']
    item = new mk.m11s.SimpleJointItem symbol, @joints[NiTE.HEAD]
    item.view.scale 1.5
    @items.push item

  addFlowers: () ->
    symbs = ['flower1.svg', 'flower2.svg', 'flower3.svg']
    parts = @getParts ['leftLowerLeg', 'rightLowerArm', 'leftUpperArm', 'leftLowerArm', 'rightUpperArm', 'rightLowerArm' ]
    for p in parts
      if Math.random() > 0.5
        sname = symbs[Math.floor(Math.random()*symbs.length)]
        symbol = @assets.symbols.peaks[sname]
        item = new mk.m11s.SimplePartItem symbol, p
        # item.view.scale Math.random()*0.8 + 1
        item.view.rotation = Math.floor(Math.random()*2) * 180
        @items.push item