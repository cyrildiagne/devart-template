class mk.m11s.stripes.Stripes

  constructor: (@settings, @torso, numStripes) ->
    @view = new paper.Group()
    @stripes = []
    # @velTracker = new mk.helpers.JointVelocityTracker @joints.slice(0, numStripes)

    w = window.viewport.width * 2
    h = window.viewport.height * 1.5
    @bg = new paper.Path.Rectangle(-w, -h*0.5, w*2, h)
    @bg.rotate 25
    @bg.position.y = (window.viewport.height + @bg.bounds.height*0.6) * 0.5
    # @bg = new paper.Path.Rectangle(-w*0.5, -h*0.5, w*2, h)
    @bg.fillColor = '#' + @settings.palette.skin.toString 16 #'black'
    @view.addChild(@bg)

    colors = [
      # @settings.palette.skin
      @settings.palette.blue
      @settings.palette.cream
      @settings.palette.lightBlue
      @settings.palette.lightRed
      @settings.palette.whiteGreen
    ]
    
    @speed = 1.5
    @introSpeed = 0.1

    rngk = 'Stripes'
    y = -h * 0.4
    for i in [0...numStripes]
      
      y += (rng(rngk)-0.5) * 150 + ((w*0.8)/numStripes)
      # s = new paper.Path.Rectangle(0, 0, w*0.75, rng(rngk)*150+10)
      s = new paper.Path.Rectangle(0, 0, h*2, rng(rngk)*120+10)
      s.transformContent = false
      s.pivot = new paper.Point h, s.bounds.height*0.5
      s.position = [0,window.viewport.height*(0.5 + rng(rngk))]
      # s.position.x = -s.bounds.width * 0.5
      # s.position.y = 0
      # s.initPosition = {x:s.position.x , y:s.position.y }
      # s.count = rng(rngk) * 100
      # s.amplitude = rng(rngk) * h * 0.5
      # s.initPosition = s.position.clone()
      # s.vel = 0
      s.rotate 25
      s.fillColor = '#' + colors.seedRandom(rngk).toString(16)
      s.speed = rng('stripe') * 0.01
      @view.addChild(s)
      @stripes.push s
    
  addStripe: () ->


  clean: () ->
    for s in @stripes
      s.remove()
    @stripes.splice 0, @stripes.length

  update: () ->
    # @velTracker.update()

    if @bg.position.y > 0
      @introSpeed += 0.025
      @bg.position.y -= @introSpeed
      sp = @introSpeed
    else
      sp = @speed
      if @speed < 2
        @speed += 0.0005
    for s,i in @stripes
      # vel = Math.sqrt(@velTracker.get(i)) * 0.003 + 0.001
      # s.position.x = @torso.x
      # s.count += 0.1
      # s.rotation += 1
      s.position.y -= s.speed + sp
      if s.position.y < -window.viewport.height * 0.5
        s.position.y += window.viewport.height + 100
    return