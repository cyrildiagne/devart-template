class mk.m11s.tribal.Pattern
  
  constructor : (@joints) ->

    @view = new paper.Group()
    @view.transformContent = false
    @view.z = -3000

    @lines = []
    @numLines = 5
    @resolution = 10
    @thickness = 80
    @space = @thickness * 2.5
    @color = mk.Scene::settings.getHexColor 'cream'

    @container = new paper.Group()
    @container.pivot = new paper.Point 0,0
    @container.transformContent = false
    @view.addChild @container

    @sinDeform = 0
    @bDeform = false
    @time = 0
    h = window.viewport.height / (@resolution-1)

    @prevJntsVel = []
    for i in [0...2]
      @prevJntsVel[i] =
        x : @joints[i].x
        y : @joints[i].y

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

    if !@bDeform then return

    vel = 0
    for i in [0...2]
      p = @prevJntsVel[i]
      jx = @joints[i].x
      jy = @joints[i].y
      vel += (jx-p.x)*(jx-p.x) + (jy-p.y)*(jy-p.y)
      p.x = jx
      p.y = jy
    vel /= 2

    if vel > 100 then vel = 100
    speed = 0.005
    if @sinDeform > speed
      speed = 0.001
    @sinDeform += (vel - @sinDeform) * speed * dt

    @time+=0.07
    for r in [0...@resolution]
      # t = @time / 5000 * @sinDeform
      t = @time
      x = Math.sin(t+r) * @sinDeform
      for l in @lines
        l.segments[r].point.x = x