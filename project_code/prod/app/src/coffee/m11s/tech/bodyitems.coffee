class mk.m11s.tech.BodyItems extends mk.m11s.base.BodyItems

  setupItems : ->
    @color = new paper.Color() #'#151515'
    @color.brightness = 0.06
    @updateBodyColor()
    @bgStrombo = false
    @addTrails()
    @addLinks()
    @addSculpt()

    @modes = [@trails, @links, @sculpt]
    # @stromboInterval()
    @modeItvlTween = null
    @currMode = 0
    @switchModeDelay = 83 * 8 * 2
    @switchModeInterval()

    @numBgFlash = @numPersoFlash = 0

  onMusicEvent : (evId) ->
    switch evId
      when 0
        # @brightnessInterval()
        # @stromboInterval()
        @modeItvlTween.stop()
        @switchModeDelay = 4784 #83 * 8 * 7
        @switchModeInterval()
      when 1
        @modeItvlTween.stop()
        @stromboInterval()

  clean : ->
    super()
    setBackgroundColor '#000'

  stromboInterval : =>

    @nextMode()
    @numBgFlash = @numPersoFlash = 0
    switch @currMode
      when 0 then @stromboBgInterval()
      when 1 then @stromboLinksInterval()
      when 2 then @stromboPersoInterval()
    
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

  nextMode : ->
    if @currMode != -1
      prev = @modes[@currMode]
      prev.setVisible false

    @currMode++
    if @currMode > 2 then @currMode = 0

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