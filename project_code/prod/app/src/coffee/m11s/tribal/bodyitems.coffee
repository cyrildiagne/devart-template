class mk.m11s.tribal.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @addHead()
    @addFeathers()
    @addFire()
    # for k,l of @sounds.loops.tribal
      # if k != 'basse_b' && k != 'deltafeu_b'
      # l.play()
      # if(k != 'tactac')
      #   l.volume 0
    
  addHead: ->
    symbol = @assets.symbols.tribal['head']
    MaskClass = m11Class 'Mask'
    item = new MaskClass symbol, @joints[NiTE.HEAD]
    @items.push item

  addFeathers: ->
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

  addFire: ->
    colors = [
      # @settings.palette.cream
      @settings.palette.lightRed
      @settings.palette.red
    ]
    @fire = new (m11Class 'Fire') colors
    @fire.view.position.x = -200
    @fire.view.position.y = 300
    @items.push @fire

  update: (dt) ->
    super dt
    
    lh = @joints[NiTE.LEFT_HAND]
    rh = @joints[NiTE.RIGHT_HAND]
    head = @joints[NiTE.HEAD]
    torso = @joints[NiTE.TORSO]
    lh_pct = (lh.y-torso.y) / (head.y-torso.y) * 0.5
    rh_pct = (rh.y-torso.y) / (head.y-torso.y) * 0.5
    pct = Math.min(Math.max(0, lh_pct+rh_pct), 1)
    @fire.setAmp pct

    #snd = @sounds.loops.tribal.deltafeu_b
    #snd.volume pct+0.2