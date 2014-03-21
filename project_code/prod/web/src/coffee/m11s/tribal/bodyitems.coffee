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
    part = (@getParts ['leftLowerArm'])[0]
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 8, 0.7
    @items.push item

    part = (@getParts ['rightLowerArm'])[0]
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 3, 0
    @items.push item

    # part = (@getParts ['pelvis'])[0]
    # item = new (m11Class 'FeatherGroup') @settings, part.joints[0], part.joints[1], 6
    # @items.push item

    part = (@getParts ['rightLowerLeg'])[0]
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 6, 0.3
    @items.push item

    part = (@getParts ['leftLowerLeg'])[0]
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 2, 0
    @items.push item