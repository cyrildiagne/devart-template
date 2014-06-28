class mk.m11s.tiroirs.Background
  
  constructor : () ->

    @view = new paper.Group()
    @view.transformContent = false
    @view.z = -3000

    @lines = []
    @numLines = 6
    @resolution = 10
    @thickness = window.viewport.width / (@numLines*2)
    @space = @thickness * 2

    @color = mk.Scene::settings.getHexColor 'blue'
    setBackgroundColor mk.Scene::settings.getHexColor('lightBlue')

    @container = new paper.Group()
    @container.pivot = new paper.Point 0,0
    @container.transformContent = false
    @view.addChild @container

    @sinDeform = 0
    @bDeform = false
    @time = 0
    h = window.viewport.height / (@resolution-1)

    for i in [0...@numLines]
      l = new paper.Path
        strokeColor : @color
        strokeWidth : @thickness
      for r in [0...@resolution]
        y = r*h
        l.add [0, y]
      @container.addChild l
      @lines.push l

      l.transformContent = false
      l.position.x = @space*i
      l.position.y = -window.viewport.height*1.5
      # l.scaling = new paper.Point(1,0.01);
      new TWEEN.Tween(l.position)
      .to({y:window.viewport.height*0.5}, 1500)
      .delay(i*200+1000)
      .start(window.currentTime)
      .onComplete =>
        @bDeform = true
    
    @container.position.x = -@container.bounds.width*0.5
    @container.position.y = -@container.bounds.height*0.5

  update : (dt) ->
    #...