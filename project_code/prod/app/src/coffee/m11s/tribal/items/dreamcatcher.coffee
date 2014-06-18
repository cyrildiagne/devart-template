class mk.m11s.tribal.DreamCatcher

  constructor : (@head) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0

    @panels = []
    @amp = 0

    numPanels = 6
    colors = ['red', 'lightBlue', 'cream']
    for i in [0...numPanels]

      panel = null
      pct = i/numPanels
      switch i
        when 1, 3, 5
          symb = mk.Scene::assets['circle_'+((i+1)/2)]
          panel = symb.place()
          panel.dScale = pct * 1.5 + 0.3
        else
          radius = pct * 300 + 100
          panel = new paper.Path.Circle [0,0], radius
          panel.dScale = 1
          # colorId = rngi('dchr',0,colors.length-1)
          color = colors.splice(0, 1)[0]
          panel.fillColor = mk.Scene::settings.getHexColor color
      
      if panel
        panel.baseRotVel = (rng('dchr')-0.5) * 2
        panel.pct = pct
        @view.insertChild 0,panel
        @panels.push panel

        panel.time = pct * Math.PI / 2
        panel.showing = false

        panel.transformContent = false
        panel.scaling = 0.01
        panel.currentScale = panel.dScale

        do (panel, i) ->
          s = 0.01
          new TWEEN.Tween({s:0.01}).to({s:panel.dScale}, 700)
          .delay((numPanels-i)*100)
          .easing( TWEEN.Easing.Quadratic.Out )
          .onUpdate(-> panel.scaling = @s )
          .onComplete(-> panel.showing = true)
          .start window.currentTime

  remove : (callback) ->
    numPanels = @panels.length
    for i in [0...numPanels]
      panel = @panels[i]
      panel.showing = false
      do (panel, i) ->
        new TWEEN.Tween({s:panel.dScale}).to({s:0.01}, 700)
        .delay((numPanels-i)*100)
        .easing( TWEEN.Easing.Quadratic.Out )
        .onUpdate(-> panel.scaling = @s )
        .start window.currentTime
    delayed numPanels*100+700, callback

  setAmp : (@amp) ->
    #...

  update : (dt) ->
    
    for p in @panels
      pct = (1-p.pct)
      dx = @head.x * pct
      dy = @head.y * pct * 0.3
      speed = 0.0015 + pct * 0.0035
      p.position.x += (dx - p.position.x) * speed * dt
      p.position.y += (dy - p.position.y) * speed * dt
      p.rotate (@amp + 1) * p.baseRotVel
      if p.showing
        ds = p.dScale + Math.sin(p.time) * 0.15
        p.currentScale += (ds-p.currentScale) * 0.0025 * dt
        p.scaling = p.currentScale
        p.time += 0.05