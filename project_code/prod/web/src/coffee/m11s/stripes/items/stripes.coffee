class mk.m11s.stripes.Stripes

  constructor: (@settings, @torso, numStripes) ->
    @view = new paper.Group()
    @stripes = []
    # @velTracker = new mk.m11s.JointVelocityTracker @joints.slice(0, numStripes)

    w = window.viewport.width * 2
    h = window.viewport.height
    bg = new paper.Path.Rectangle(-w*0.5, -h*0.5, w, h)
    bg.fillColor = 'white'
    @view.addChild(bg)

    colors = [
      @settings.palette.skin
      @settings.palette.blue
      @settings.palette.beige
      @settings.palette.lightRed
      @settings.palette.whiteGreen
    ]
    
    rngk = 'Stripes'
    for i in [0...numStripes]
      s = new paper.Path.Rectangle(0, 0, w*0.6, rng(rngk)*20+30)
      
      s.position.x = 0
      s.position.y = (rng(rngk)-0.5)*h*0.6
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
      s.position.x = @torso.x
      s.count += 0.1
    return