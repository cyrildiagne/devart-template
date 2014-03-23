class mk.m11s.tribal.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addHead()
    @addFeathers()
    
  addHead: () ->
    symbol = @assets.symbols.tribal['head.svg']
    MaskClass = m11Class 'Mask'
    item = new MaskClass symbol, @joints[NiTE.HEAD]
    @items.push item

  addFeathers: () ->
    part = @getPart 'leftLowerArm'
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 8, 0.7
    @items.push item

    part = @getPart 'rightLowerArm'
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 3, 0
    @items.push item

    # part = @getPart 'pelvis'
    # item = new (m11Class 'FeatherGroup') @settings, part.joints[0], part.joints[1], 6
    # @items.push item

    part = @getPart 'rightLowerLeg'
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 6, 0.3
    @items.push item

    part = @getPart 'leftLowerLeg'
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 2, 0
    @items.push item