class mk.m11s.tiroirs.Drawer

  constructor: (@symbol, @part, opt) ->
    @rngk = 'Drawer'+@part

    @view = new paper.Group()
    # @view.addChild @symbol.place()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    
    # @side = if rng(@rngk) > 0.5 then 1 else -1
    @side = 1
    @left = @right = @front = @back = @bottom = null
    @setup()
    @show opt.scale, 0

    @scale = opt.scale

    @follower = new mk.helpers.PartFillFollower @view, @part, opt.weights, opt.z + 100
    @drawerItem = null

    @sfxType = 1

    @openCallback = null
    @maxOpenness = 60

    @openness = 0
    @dOpenness = 0
    @time = 0
    @isOpen = false
    @isChanging = false

    @isGrowing = false
    @growSpeed = 0.5 + rng('dr') * 2

  setup : ->
    if rng(@rgnk+'setup') > 0.3
      c1 = ['beige', 'cream']
      @sfxType = 2
    else c1 = ['lightBlue', 'blue']
    if @part.name is 'torso'
      c2 = ['red', 'darkGray']
    else c2 = ['darkGray', 'red']

    @setupBack c2[1]
    @setupSides c1[1]
    @setupFront c1[0], c2[0]

  show : (scale, delay) ->
    v = @view
    rdm = rng(@rdmk+'show')
    v.visible = false
    tween = new TWEEN.Tween({ scale: 0.01 })
     .to({ scale: scale }, 1000)
     # .delay(delay*(2650))
     .easing( TWEEN.Easing.Quadratic.Out )
     .onStart( -> v.visible = true )
     .onUpdate(-> v.scaling = @scale )
     .onComplete(=>
     #    @bReleaseBirds = true
     )
     .start window.currentTime

  growToInfinity : ->
    @isGrowing = true

  growItem : ->
    rep = false
    if !@drawerItem
      sym = ['cane', 'belt', 'ladder', 'umbrella'].seedRandom 'growItem'
      symbol = mk.Scene::assets[sym]
      @drawerItem = new mk.m11s.tiroirs.DrawerItem symbol, @
      rep = true
    @drawerItem.show()
    return rep

  shrinkItem : (clean=false, callback)->
    if @drawerItem
      @drawerItem.hide =>
        if callback then callback()
        if clean 
          @drawerItem.view.remove()
          @drawerItem = null

  setupFront : (color, handleColor) ->
    @front = new paper.Group
    @front.pivot = new paper.Point 55,30
    @front.transformContent = false

    @frontP = new paper.Path.Rectangle
      point : [0, 0]
      size  : [110, 60]
      fillColor : mk.Scene::settings.getHexColor(color)
    @front.addChild @frontP

    @handle = new paper.Path.Circle
      center : [50, 30]
      radius : 8
      fillColor : mk.Scene::settings.getHexColor(handleColor)
    @front.addChild @handle

    @view.addChild @front

  setupBack : (color) ->
    @back = new paper.Path.Rectangle
      point : [-55, -30]
      size  : [110, 60]
      fillColor : mk.Scene::settings.getHexColor(color)
    @view.addChild @back

  setupBottom : (color) ->
    @bottom = new paper.Path
    @bottom.add new paper.Point() for i in [0...4]
    @bottom.fillColor = mk.Scene::settings.getHexColor(color)
    @view.addChild @bottom

  setupSides : (color) ->
    @left = new paper.Path
    @left.add new paper.Point() for i in [0...4]
    @left.fillColor = mk.Scene::settings.getHexColor(color)
    @view.addChild @left

    @right = new paper.Path
    @right.add new paper.Point() for i in [0...4]
    @right.fillColor = mk.Scene::settings.getHexColor(color)
    @view.addChild @right

  toggle : (silent) ->
    if @isChanging or @isGrowing
      return false
    if @isOpen then @dOpenness = 0
    else @dOpenness = 1
    @isOpen = !@isOpen
    @isChanging = true
    if @isOpen
      mk.Scene::sfx.play 'drawerOpen' + @sfxType
      if !silent
        @openCallback @ if @openCallback
    else
      mk.Scene::sfx.play 'drawerClose' + @sfxType
      if !silent
        @closeCallback @ if @closeCallback

  updateOpenness : ->
    @left.segments[0].point = @front.bounds.topLeft
    @left.segments[1].point = @front.bounds.bottomLeft
    @left.segments[2].point = @back.bounds.bottomLeft
    @left.segments[3].point = @back.bounds.topLeft

    @right.segments[0].point = @front.bounds.topRight
    @right.segments[1].point = @front.bounds.bottomRight
    @right.segments[2].point = @back.bounds.bottomRight
    @right.segments[3].point = @back.bounds.topRight

  update : (dt) ->
    @follower.update()

    if @isGrowing
      @front.position.x += @growSpeed * @side
      @front.position.y += @growSpeed * 0.5
    else
      @openness += (@dOpenness-@openness) * 0.005 * dt
      if @isChanging
        if Math.abs(@dOpenness-@openness) < 0.1
          @isChanging = false
      @front.position.x = @openness * @maxOpenness * @side
      @front.position.y = @openness * @maxOpenness * 0.5
    
    @updateOpenness()

    if @drawerItem
      @drawerItem.update dt