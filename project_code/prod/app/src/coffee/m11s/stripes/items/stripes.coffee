class mk.m11s.stripes.Stripes

  constructor: (@settings, @torso, numStripes) ->
    @view = new paper.Group()
    @stripes = []
    # @velTracker = new mk.helpers.JointVelocityTracker @joints.slice(0, numStripes)

    w = window.viewport.width * 2
    h = window.viewport.height
    bg = new paper.Path.Rectangle(-w, -h*0.5, w*2, h)
    # bg = new paper.Path.Rectangle(-w*0.5, -h*0.5, w*2, h)
    bg.fillColor = '#' + @settings.palette.skin.toString 16 #'black'
    @view.addChild(bg)

    colors = [
      # @settings.palette.skin
      @settings.palette.blue
      @settings.palette.cream
      @settings.palette.lightBlue
      @settings.palette.lightRed
      @settings.palette.whiteGreen
    ]
    
    rngk = 'Stripes'
    y = -h * 0.4
    for i in [0...numStripes]
      
      y += (rng(rngk)-0.5) * 150 + ((w*0.8)/numStripes)
      # s = new paper.Path.Rectangle(0, 0, w*0.75, rng(rngk)*150+10)
      s = new paper.Path.Rectangle(0, 0, h*2, rng(rngk)*120+10)
      s.position.x = y
      s.position.y = 0
      s.initPosition = {x:s.position.x , y:s.position.y }
      s.count = rng(rngk) * 100
      s.amplitude = rng(rngk) * h * 0.5
      s.initPosition = s.position.clone()
      s.vel = 0
      s.rotate 35
      s.fillColor = '#' + colors.seedRandom(rngk).toString(16)
      s.transformContent = false
      @view.addChild(s)
      @stripes.push s
    
  addStripe: () ->


  clean: () ->
    for s in @stripes
      s.remove()
    @stripes.splice 0, @stripes.length

  update: () ->
    # @velTracker.update()
    for s,i in @stripes
      # vel = Math.sqrt(@velTracker.get(i)) * 0.003 + 0.001
      # s.position.x = @torso.x
      s.count += 0.1
    return