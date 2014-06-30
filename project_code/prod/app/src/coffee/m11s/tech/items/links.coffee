class mk.m11s.tech.Link

  color : []

  constructor : (@j1, @j2) ->
    @white = new paper.Color(255,255,255)
    @view = new paper.Group()
    @view.transformContent = false

    @history = []
    @numUpdateSinceSave = 0
    @numUpdateBetweenSave = 0
    @historyLength = 20

    @newPath()

    @visible = false
    @dWidth = 1
    @strombo = false
    # @impulse()

  update : (dt) ->
    if ++@numUpdateSinceSave >= @numUpdateBetweenSave
      if @history.length > @historyLength
        @history.shift().remove()
      @newPath()
      @numUpdateSinceSave = 0

    for i in [0...@history.length-1]
      p = @history[i]
      # p.strokeWidth *= 0.95
      # p.strokeAlph
      p.strokeColor.brightness *= 0.97

    # @path.strokeWidth += (@dWidth - @path.strokeWidth) * 0.02 * dt
    @path.segments[0].point.x = @j1.x
    @path.segments[0].point.y = @j1.y
    @path.segments[1].point.x = @j2.x
    @path.segments[1].point.y = @j2.y

  newPath : ->
    @path = new paper.Path()
    @path.segments = [[0,0],[0,0]]
    @path.strokeWidth = 16
    @path.strokeCap = 'round'
    @path.strokeColor = mk.m11s.tech.Link::color
    @path.strokeColor.brightness *= 1.1
    @history.push @path
    @view.addChild @path

  # impulse : ->
  #   @path.strokeColor = @currColor = mk.m11s.tech.Link::colors.random()
  #   @dWidth = Math.random() * 20 + 1 + 20
  #   delayed 60+20*rngi('lnk',0,6), => @impulse()
  toggleStrombo : () ->
    return
    @strombo = !@strombo
    @path.strokeColor = if @strombo then @white else @color

  clear : ->
    @history.shift().remove() while @history.length


class mk.m11s.tech.Links
  constructor : (@joints) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 9999

    c = ['lightRed', 'blue'].seedRandom('techlnk')
    color = new paper.Color mk.Scene::settings.getHexColor(c)
    mk.m11s.tech.Link::color = color

    @links = []
    for jn in ['SHOULDER', 'HIP', 'KNEE', 'FOOT','ELBOW', 'HAND']
      j1 = @joints[NiTE['LEFT_'+jn]]
      j2 = @joints[NiTE['RIGHT_'+jn]]
      link = new mk.m11s.tech.Link j1, j2
      @links.push link
      @view.addChild link.view

  update : (dt) ->
    if @visible
      for l in @links
        l.update(dt)

  toggleStrombo : () ->
    l.toggleStrombo() for l in @links

  setVisible : (@visible) ->
    @view.visible = @visible
    if @view.visible
      link.clear() for link in @links
    if @visible
      c = ['lightRed', 'blue'].seedRandom('techlnk')
      color = new paper.Color mk.Scene::settings.getHexColor(c)
      mk.m11s.tech.Link::color = color
