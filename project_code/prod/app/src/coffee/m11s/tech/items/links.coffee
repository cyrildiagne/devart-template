class mk.m11s.tech.Link

  colors : []

  constructor : (@j1, @j2) ->
    @white = new paper.Color(255,255,255)
    @path = new paper.Path()
    @path.segments = [[0,0],[0,0]]
    @path.strokeWidth = 5
    @path.strokeCap = 'round'
    @path.strokeColor = 'black'
    @visible = false
    @dWidth = 1
    @strombo = false
    @impulse()
  update : (dt) ->
    @path.strokeWidth += (@dWidth - @path.strokeWidth) * 0.02 * dt
    @path.segments[0].point.x = @j1.x
    @path.segments[0].point.y = @j1.y
    @path.segments[1].point.x = @j2.x
    @path.segments[1].point.y = @j2.y
  impulse : ->
    @path.strokeColor = @currColor = mk.m11s.tech.Link::colors.random()
    @dWidth = Math.random() * 20 + 1
    delayed 60+20*rngi('lnk',0,6), => @impulse()
  toggleStrombo : () ->
    @strombo = !@strombo
    @path.strokeColor = if @strombo then @white else @color


class mk.m11s.tech.Links
  constructor : (@joints) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 9999

    for c in ['skin','cream','beige','red','lightRed']
      color = new paper.Color mk.Scene::settings.getHexColor(c)
      mk.m11s.tech.Link::colors.push color

    @links = []
    for jn in ['SHOULDER', 'HIP', 'KNEE', 'FOOT','ELBOW', 'HAND']
      j1 = @joints[NiTE['LEFT_'+jn]]
      j2 = @joints[NiTE['RIGHT_'+jn]]
      link = new mk.m11s.tech.Link j1, j2
      @links.push link
      @view.addChild link.path

  update : (dt) ->
    if @visible
      for l in @links
        l.update(dt)

  toggleStrombo : () ->
    l.toggleStrombo() for l in @links

  setVisible : (@visible) ->
    @view.visible = @visible