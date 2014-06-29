class mk.m11s.tiroirs.Background
  
  constructor : () ->

    @view = new paper.Group()
    @view.transformContent = false
    @view.z = -3000
    @view.pivot = new paper.Point 0,0

    @lines = []
    @numLines = 6
    @resolution = 2
    @thickness = window.viewport.width / (@numLines*2)
    @space = @thickness * 2

    
    # setBackgroundColor mk.Scene::settings.getHexColor('lightBlue')

    @container = new paper.Group()
    @container.pivot = new paper.Point 0,0
    @container.transformContent = false
    @view.addChild @container

    @sinDeform = 0
    @bDeform = false
    @time = 0

    console.log 'add bg'

    c1 = mk.Scene::settings.getHexColor 'blue'
    @addLines c1

    c2 = mk.Scene::settings.getHexColor 'lightBlue'
    @addLines c2, @thickness, false
    
    @container.position.x = -@container.bounds.width*0.5
    @container.position.y = -@container.bounds.height*0.5

  update : (dt) ->
    #...

  removeLines : ->
    console.log 'remove bg'
    for l,i in @lines
      do (l,i) ->
        sc = new paper.Point 1,1
        new TWEEN.Tween(sc)
          .to({y:0}, 800)
          .onUpdate(->
            l.scaling = sc
          )
          .delay(i*50)
          .start(window.currentTime)

  addLines : (color, offset=0, bInverted=false) ->
    
    h = window.viewport.height / (@resolution-1)

    for i in [0..@numLines]
      l = new paper.Path
        strokeColor : color
        strokeWidth : @thickness
      for r in [0...@resolution]
        y = r*h
        l.add [0, y]
      @container.addChild l
      @lines.push l

      l.transformContent = false
      l.position.x = @space*i + offset

      if bInverted
        l.position.y = window.viewport.height*.5
        new TWEEN.Tween(l.position)
        .to({y:-window.viewport.height*0.5}, 1500)
        .delay(i*200+1000)
        .start(window.currentTime)
      else
        l.position.y = -window.viewport.height*1.5
        new TWEEN.Tween(l.position)
        .to({y:window.viewport.height*0.5}, 1500)
        .delay(i*200+1000)
        .start(window.currentTime)