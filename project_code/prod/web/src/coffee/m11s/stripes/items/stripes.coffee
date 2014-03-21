class mk.m11s.stripes.Stripes

  constructor: (@settings, @joints, numStripes) ->
    @view = new paper.Group()
    @stripes = []
    @velTracker = new mk.m11s.JointVelocityTracker @joints

    w = paper.view.viewSize.width
    h = paper.view.viewSize.height
    bg = new paper.Path.Rectangle(-w*0.5, -h*0.5, w, h)
    bg.fillColor = '#' + @settings.palette.lightBlue.toString(16)
    @view.addChild(bg)

    colors = [
      @settings.palette.skin
      @settings.palette.blue
      @settings.palette.beige
      @settings.palette.lightRed
      @settings.palette.whiteGreen
    ]
    
    for i in [0...numStripes]
      h = paper.view.viewSize.height
      s = new paper.Path.Rectangle(0, 0, w*0.6, Math.random()*20+30)
      
      s.position.x = 0
      s.position.y = (Math.random()-0.5)*h*0.6

      s.initPosition = {x:s.position.x , y:s.position.y }
      s.count = Math.random() * 100
      s.amplitude = Math.random() * h * 0.5
      s.vel = 0
      
      s.rotate 35

      c = colors[Math.floor(Math.random()*colors.length)]
      s.fillColor = '#' + c.toString(16)
      
      @view.addChild(s)
      @stripes.push s
    

  clean: () ->
    for s in @stripes
      s.remove()
    @stripes.splice 0, @stripes.length

  update: () ->
    @velTracker.update()
    for s,i in @stripes
      vel = Math.sqrt(@velTracker.get(i)) * 0.003 + 0.001
      s.vel += (vel-s.vel) * 0.05
      s.count += s.vel
      s.position.y = s.initPosition.y + Math.sin(s.count) * s.amplitude
    return