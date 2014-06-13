class mk.m11s.tech.BodyItems extends mk.m11s.base.BodyItems

  setupItems : ->
    @color = new paper.Color '#151515'
    @updateBodyColor()
    @bgStrombo = false
    @addLines()

  onMusicEvent : (evId) ->
    switch evId
      when 0
        break
        # @brightnessInterval()
        # @stromboInterval()

  clean : ->
    super()
    setBackgroundColor '#000'


  brightnessInterval : =>
    
    beat = 83
    if @bgStrombo
      # b = if Math.random() > 0.5 then 255 else 0
      if @bgColor is 'f' then @bgColor = '0'
      else @bgColor = 'f'
      b = @bgColor
      setBackgroundColor '#'+b+b+b
      delay = beat
    else
      b = Math.random()
      if b > 0.3 and b < 0.7 then b = 0
      # if @color.brightness is 0 then @color.brightness = 255
      # else @color.brightness = 0
      @color.brightness = b
      @updateBodyColor()
      delay = beat*(1+Math.floor(Math.random()*5))
    
    delayed delay, @brightnessInterval

  stromboInterval : =>
    @bgStrombo = !@bgStrombo
    if @bgStrombo
      rdmInt = [8, 16, 24].random()
      @color.brightness = 0
      @updateBodyColor()
    else
      rdmInt = 10 + Math.floor(Math.random()*50)
      setBackgroundColor '#000'
    beat = 83
    delayed beat*rdmInt, @stromboInterval

  updateBodyColor : ->
    # for p in @parts
    #   p.view.visible = false 
    for p in @parts
      p.setColor @color, false

  addLines : ->
    parts = @getParts ['leftUpperArm', 'leftLowerArm','rightUpperArm','rightLowerArm']
    @lines = new mk.m11s.tech.Lines parts, @getPart('head'), @getPart('pelvis')
    @items.push @lines