class mk.m11s.tribal.BodyItems extends mk.m11s.base.BodyItems

  setupItems : ->
    delayed 500, => @addMask()
    @deform = false
    @feathers = []

    # @startRayman()

    # for k,l of @sounds.loops.tribal
      # if k != 'basse_b' && k != 'deltafeu_b'
      # l.play()
      # if(k != 'tactac')
      #   l.volume 0
    
  addMask : ->
    symbol = @assets.symbols.tribal['head']
    MaskClass = m11Class 'Mask'
    @mask = new MaskClass symbol, @joints[NiTE.RIGHT_HAND], @joints[NiTE.HEAD]
    @mask.maskOnCallback = => @startFire()
    @items.push @mask

  onMusicEvent : (evId) ->
    switch evId
      when 3
        @addFeathers()
      when 4
        @deform = true
        for feather in @feathers
          for f in feather.feathers
            f.deform = true
      when 5
        @stopFire()
        delayed 1000, =>
          @addStars()

  startFire : ->
    @addFire()
    @addShadow()

  stopFire : ->
    fire = @fire
    new TWEEN.Tween({pct:@fire.amp}).to({pct:0}, 1000)
    .start(window.currentTime)
    .onUpdate(->
      fire.setAmp @pct
    )
    .onComplete =>
      fire.clean()
      fire.view.remove()
      @items.splice @items.indexOf(fire),1
    @fire = null

    new TWEEN.Tween(@shadow.view).to({opacity:0}, 1000)
    .start(window.currentTime)
    .onComplete =>
      @shadow.view.remove()
      @items.splice @items.indexOf(@shadow),1
      @shadow = null

  addFeathers : ->

    part = @getPart 'leftLowerArm'
    item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 8, 0.7
    @feathers.push item
    @items.push item

    boomTime = 760

    delayed boomTime, =>
      part = @getPart 'rightLowerArm'
      item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 3, 0
      @feathers.push item
      @items.push item

    delayed boomTime*2, =>
      part = @getPart 'rightLowerLeg'
      item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 6, 0.3
      @feathers.push item
      @items.push item

    delayed boomTime*3, =>
      part = @getPart 'leftLowerLeg'
      item = new (m11Class 'FeatherGroup') @settings, part.joints[1], part.joints[0], 2, 0
      @feathers.push item
      @items.push item

  addStars : ->
    @stars = new mk.m11s.tribal.Stars @joints[NiTE.HEAD]
    @items.push @stars

  addFire : ->
    colors = [
      # @settings.palette.cream
      @settings.palette.lightRed
      @settings.palette.red
    ]
    @fire = new (m11Class 'Fire') colors
    @fire.view.position.x = -200
    @fire.view.position.y = 550
    @items.push @fire

  addShadow : ->
    head = @joints[NiTE.HEAD]
    leftFoot = @joints[NiTE.LEFT_FOOT]
    rightFoot = @joints[NiTE.RIGHT_FOOT]
    shadow = new (m11Class 'Shadow') head, leftFoot, rightFoot
    @items.push shadow

    shadow.view.opacity = 0
    new TWEEN.Tween(shadow.view).to({opacity:1}, 1000)
    .onComplete(=> @shadow = shadow)
    .start window.currentTime

  # ---

  update : (dt) ->
    super dt

    if @fire
      lh = @joints[NiTE.LEFT_HAND]
      rh = @joints[NiTE.RIGHT_HAND]
      head = @joints[NiTE.HEAD]
      torso = @joints[NiTE.TORSO]
      lh_pct = (lh.y-torso.y) / (head.y-torso.y) * 0.5
      rh_pct = (rh.y-torso.y) / (head.y-torso.y) * 0.5
      pct = Math.min(Math.max(0, lh_pct+rh_pct), 1)
      @fire.setAmp pct
      # if @shadow
      #   @shadow.view.opacity += (pct * 0.5 + 0.2 - @shadow.view.opacity) * 0.0025 * dt

    #snd = @sounds.loops.tribal.deltafeu_b
    #snd.volume pct+0.2