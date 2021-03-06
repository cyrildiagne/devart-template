class mk.m11s.tech.SculptShape

  color : null

  constructor : (@j1, @j2, @color, @mainView,@isArm = false) ->
    @paths = []

    @visible = false
    
    @addNew()

    @max = 10
    @length = 10
    @bAdd = 0

    @imp = 0
    @impulseMax = rngi('sclpt', 2, 8)

    # @impulse()

  addNew : ->
    if !@visible then return

    @currPath = new paper.Path()
    @currPath.segments = [[@j1.x,@j1.y], [@j2.x,@j2.y], [@j2.x,@j2.y], [@j1.x,@j1.y]]
    @currPath.fillColor = @color.clone()
    @currPath.initColor = @color.clone()
    @currPath.fillColor.brightness += 0.3
    # @currPath.visible = @visible
    # @view.addChild @currPath
    if @isArm
      @currPath.z = (@j1.z + @j2.z) / 2 + 1000 + rng('sclpt')*50
    else
      @currPath.z = (@j1.z + @j2.z) / 2 - 1000 + rng('sclpt')*50
    @paths.push @currPath
    @mainView.addChild @currPath
    # if @view.children.length > @length
    #   @view.firstChild.remove()
    if @paths.length > @length
      @paths.shift().remove()

    for c in @paths
      c.initColor.brightness -= 0.05

  update : (dt) ->
    if !@visible then return

    @currPath.segments[2].point.x = @j2.x
    @currPath.segments[2].point.y = @j2.y
    @currPath.segments[3].point.x = @j1.x
    @currPath.segments[3].point.y = @j1.y

    # if @view.children.length > 2
    #   p = @view.firstChild
    if @paths.length > 2
      p = @paths[0]
      p.segments[0].point.x += (p.segments[3].point.x - p.segments[0].point.x) * 0.1
      p.segments[0].point.y += (p.segments[3].point.y - p.segments[0].point.y) * 0.1
      p.segments[1].point.x += (p.segments[2].point.x - p.segments[1].point.x) * 0.1
      p.segments[1].point.y += (p.segments[2].point.y - p.segments[1].point.y) * 0.1

    if @bAdd++ > @max
      @addNew()
      @bAdd = 0

    if @imp++ > @impulseMax
      @impulse()
      @imp = 0

  impulse : ->
    # for c in @view.children
    for c in @paths
      # c.fillColor = mk.m11s.tech.SculptShape::colors.random()
      c.fillColor.brightness = c.initColor.brightness + (rng('sclpt')-0.5) * 0.1
      # delayed 160+200*Math.random(), => @impulse()

  setVisibility : (v) ->
    if v is @visible then return
    @visible = v
    if !@visible
      for c in @paths
        c.visible = @visible
    #   while @paths.length
    #     @paths.shift().remove()
    else
      while @paths.length
        @paths.shift().remove()
      @addNew()
    # for c in @paths
    #   c.visible = @visible


class mk.m11s.tech.Sculpt
  constructor : (@joints, @mainView) ->
    @view = new paper.Group()
    @view.z = -9999

    # c = ['lightBlue','blue','red','lightRed'].seedRandom('sculpt')
    c = ['lightRed', 'blue'].seedRandom('techlnk')
    color = new paper.Color mk.Scene::settings.getHexColor(c)
    mk.m11s.tech.SculptShape::color = color

    jnts = ['FOOT', 'KNEE', 'TORSO', 'SHOULDER', 'ELBOW', 'HAND']
    @shapes = []
    for side in ['LEFT_', 'RIGHT_']
      for i in [0...jnts.length-1]
        pref1 = if jnts[i] is 'TORSO' then '' else side
        pref2 = if jnts[i+1] is 'TORSO' then '' else side
        j1 = @joints[NiTE[pref1+jnts[i]]]
        j2 = @joints[NiTE[pref2+jnts[i+1]]]
        isHand = (i is 3) or (i is 4) or (i is 5)
        sclpt = new mk.m11s.tech.SculptShape j1, j2, color, @mainView, isHand
        @shapes.push sclpt
        # @view.addChild sclpt.view

  update : (dt) ->
    for s in @shapes
      s.update(dt)

  setLength : (length) ->
    sc.length = length for sc in @shapes

  setVisible : (visible) ->
    for s in @shapes
      s.setVisibility visible
    if visible
      c = ['lightRed', 'blue'].seedRandom('techlnk')
      color = new paper.Color mk.Scene::settings.getHexColor(c)
      mk.m11s.tech.SculptShape::color = color
      for s in @shapes
        s.color = color
        # for face in s.paths
        #   face.fillColor = face.initColor = color