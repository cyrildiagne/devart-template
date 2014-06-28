class mk.m11s.bulbs.DigiPlan
  constructor : (@w, @h, @bAddMask=false) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0

    @thickness = 25
    @color = new paper.Color mk.Scene::settings.getHexColor('lightRed')
    @initColor = @color.clone()

    @paths = []

    w = @w * 0.85
    h = @h * 0.85

    @left = new paper.Path()
    @left.add [-@w*0.5, -h*0.5]
    @left.add [-@w*0.5,  h*0.5]
    @paths.push @left

    @right = new paper.Path()
    @right.add [@w*0.5, -h*0.5]
    @right.add [@w*0.5,  h*0.5]
    @paths.push @right

    @top = new paper.Path()
    @top.add [-w*0.5, -@h*0.5]
    @top.add [ w*0.5, -@h*0.5]
    @paths.push @top

    @bottom = new paper.Path()
    @bottom.add [-w*0.5, @h*0.5]
    @bottom.add [ w*0.5, @h*0.5]
    @paths.push @bottom

    for p in @paths
      p.strokeWidth = @thickness
      p.strokeCap = 'round'
      p.strokeColor = @color
      @view.addChild p

    # if @bAddMask
    #   @leftMask = new paper.Path.Rectangle [-@w*1.5-@thickness*0.5+1, -@h*0.5], [@w, @h]
    #   @view.addChild @leftMask
    #   @rightMask = new paper.Path.Rectangle [@w*0.5+@thickness*0.5-1, -@h*0.5], [@w, @h]
    #   @view.addChild @rightMask
    #   @lightOff

  lightOn : ->
    # @rightMask.fillColor = @leftMask.fillColor = 'white'

  lightOff : ->
    # @rightMask.fillColor = @leftMask.fillColor = mk.Scene::settings.getHexColor 'background'

class mk.m11s.bulbs.DigiBack

  constructor : (@head, @numPanels=5) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0

    @panels = []
    @amp = 0

    for i in [0...@numPanels]
      panel = new mk.m11s.bulbs.DigiPlan window.viewport.width*0.85, window.viewport.height*0.85, (i==@numPanels-1)
      panel.pct = (i+1)/@numPanels
      panel.scale = panel.pct
      panel.time = panel.pct * 3.14 * 2
      panel.view.scaling = 0.01

      @view.addChild panel.view
      @panels.push panel

      do (panel, i) =>
        s = 0.01
        new TWEEN.Tween({s:0.01}).to({s:panel.scale}, 1000)
        .delay((@numPanels-i)*150)
        .easing( TWEEN.Easing.Quadratic.Out )
        .onUpdate(-> panel.view.scaling = @s )
        .start window.currentTime

    return

  lightOn : ->
    @panels.last().lightOn()

  lightOff : ->
    @panels.last().lightOff()

  hide : (callback) ->
    numPanels = @panels.length
    dlay = 90
    duration = 600
    for i in [0...numPanels]
      panel = @panels[i]
      panel.showing = false
      do (panel, i) ->
        new TWEEN.Tween({s:panel.scale, y:0}).to({s:0.01,y:1}, duration)
        .delay((i)*dlay)
        .easing( TWEEN.Easing.Quadratic.Out )
        .onUpdate(-> 
          # panel.view.scaling = @s
          panel.view.position.y -= @y*40
        )
        .onComplete(-> 
          panel.view.visible = false
        ).start window.currentTime
    delayed numPanels*dlay+duration, callback

  clean : ->
    @view.remove()

  setAmp : (@amp) ->
    #...

  update : (dt) ->
    for p in @panels
      pct = (1-p.pct)
      dx = -@head.x * pct * 1.5
      dy = -@head.y * (pct * 0.5)
      speed = 0.0015 + pct * 0.0035
      p.view.position.x += (dx - p.view.position.x) * speed * dt
      p.view.position.y += (dy - p.view.position.y) * speed * dt
      #...
      b = p.initColor.brightness + Math.sin(p.time) * 0.75
      p.opacity = Math.sin(p.time)
      p.time += 0.1