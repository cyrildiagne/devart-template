class mk.m11s.tech.BodyItems extends mk.m11s.base.BodyItems

  setupItems : ->
    @color = new paper.Color() #'#151515'
    @color.brightness = 0.2
    @updateBodyColor()
    @bgStrombo = false
    @addTrails()
    @addLinks()
    @addSculpt()
    @addClones()

    @modes = [@trails, @sculpt, @clones, @links]
    # @stromboInterval()
    @modeItvlTween = null
    @currMode = 0
    @switchModeDelay = 83 * 8 * 2
    @switchModeInterval()
    # @nextMode()

    @numBgFlash = @numPersoFlash = 0
    @stromboIntervalMode = 0

  onMusicEvent : (evId) ->
    return
    switch evId
      when 0
        @modeItvlTween.stop()
        @switchModeDelay = 4784 #83 * 8 * 7
        @switchModeInterval()
      when 1
        @clearCurrentMode()
        @currMode = 0
        @modeItvlTween.stop()
        @stromboInterval()
      when 2
        @stromboIntervalMode = 1
        @trails.setLength 25
        @sculpt.setLength 20

  clean : ->
    super()
    setBackgroundColor '#000'

  stromboInterval : =>

    if @stromboIntervalMode is 0 or (@stromboIntervalMode *= -1) > 0
      @nextMode()
    @numBgFlash = @numPersoFlash = 0
    switch @currMode
      when 0 then @stromboBgInterval()
      when 1 then @stromboLinksInterval()
      when 2 then @stromboPersoInterval()
      when 3 then @stromboClonesInterval()
    
    delayed 2400, @stromboInterval

  stromboBgInterval : =>

    if @bgColor is 'f' then @bgColor = '0'
    else @bgColor = 'f'
    b = @bgColor
    setBackgroundColor '#'+b+b+b
    
    if @numBgFlash++ < 11 * 2 + 1
      delayed 75, @stromboBgInterval

  stromboPersoInterval : =>

    @color.brightness = 1 - @color.brightness
    # console.log @color.brightness
    @updateBodyColor()

    beat = 83
    delay = 75 #beat*rdmInt
    if @numPersoFlash++ < 11 * 2 + 1
      delayed delay, @stromboPersoInterval

  stromboLinksInterval : =>
    @links.toggleStrombo()
    beat = 83
    delay = 75 #beat*rdmInt
    if @numPersoFlash++ < 11 * 2 + 1
      delayed delay, @stromboLinksInterval

  stromboClonesInterval : =>
    @clones.toggleStrombo()
    beat = 83
    delay = 75 #beat*rdmInt
    if @numPersoFlash++ < 11 * 2 + 1
      delayed delay, @stromboClonesInterval

  clearCurrentMode : ->
    if @currMode != -1
      prev = @modes[@currMode]
      prev.setVisible false

  nextMode : ->
    @clearCurrentMode()

    @currMode++
    if @currMode > 3 then @currMode = 0

    @modes[@currMode].setVisible true

  switchModeInterval : =>
    @nextMode()
    
    # rdmInt = [2, 4, 8, 16].random()
    # beat = 83
    # delayed beat*(rdmInt), @switchModeInterval
    @modeItvlTween = delayed @switchModeDelay, @switchModeInterval

  updateBodyColor : ->
    # for p in @parts
    #   p.view.visible = false 
    for p in @parts
      p.setColor @color, false

  addTrails : ->
    parts = @getParts ['leftUpperArm', 'leftLowerArm','rightUpperArm','rightLowerArm']
    @trails = new mk.m11s.tech.Trail parts, @getPart('head'), @getPart('pelvis')
    @items.push @trails

  addLinks : ->
    @links = new mk.m11s.tech.Links @joints
    @items.push @links

  addSculpt : ->
    @sculpt = new mk.m11s.tech.Sculpt @joints, @view
    @items.push @sculpt

  addClones : ->
    @clones = new mk.m11s.tech.Clones @parts
    @items.push @clones