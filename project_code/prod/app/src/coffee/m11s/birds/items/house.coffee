class mk.m11s.birds.House

  constructor : (@sname, @part, @hands) ->
    @view = new paper.Group()#@symbol.place()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.z = 0

    @sday = mk.Scene::assets[sname]
    @snight = mk.Scene::assets[sname+'_night']

    @view.addChild @sday.place()

    # @view.scaling = 0.01
    # @view.visible = false
    # @view.scale 0.01

    @bReleaseBirds = false
    @distMax = 30*30
    @isWiggling = false
    @isGrown = false

    @wiggle = 0
    @wiggleVal = 0

    asset = mk.Scene::assets['wildbird']
    wingColor = mk.Scene::settings.getHexColor('cream')
    @bird = new mk.m11s.birds.WildBird asset, @, wingColor
    # @view.addChild @bird.view

    @seed = sname
    weights = mk.helpers.getRandomWeights @part.joints, @seed
    @follower = new mk.helpers.PartFillFollower @view, @part, weights, 3000#rng(@seed) * 100 + 100

  show : (scale, delay) ->
    v = @view
    rdm = rng(@rdmk+'show') * 15
    tween = new TWEEN.Tween({ scale: 0.01 })
     .to({ scale: scale }, 1000)
     .delay(delay*(2650)+7000)
     .easing( TWEEN.Easing.Quadratic.Out )
     .onStart(->
        v.visible = true
     )
     .onUpdate(->
        v.scaling = @scale
     # ).onComplete(=>
     #    @bReleaseBirds = true
     )
     .start window.currentTime

  setNight :(delay=0) ->
    # @view.removeChildren()
    night = @snight.place()
    night.opacity = 0
    @view.addChild night
    v = @view
    tween = new TWEEN.Tween({ opacity: 0 })
     .to({ opacity: 1 }, 1000)
     .delay(delay)
     .easing( TWEEN.Easing.Linear.None )
     .onUpdate(->
        night.opacity = @opacity
     )
     .onComplete(=>
        @bReleaseBirds = true
        v.removeChildren 0,1
     )
     .start window.currentTime

  update : (dt) ->

    if !@view.visible then return

    p = @view.position
  
    for h in @hands
      dist = (h.x-p.x) * (h.x-p.x) + (h.y-p.y) * (h.y-p.y)
      if dist < @distMax
        @wiggle = Math.min 35, @wiggle + 5
        mk.Scene::sfx.Maison_1.play()
        if @bReleaseBirds and !@bird.isFlying
          @bird.flyAway()

    if @wiggle > 2
      @wiggle *= 0.98
      @wiggleVal += 0.2
      @view.rotation = Math.sin(@wiggleVal) * @wiggle

    @bird.update dt
    @follower.update()