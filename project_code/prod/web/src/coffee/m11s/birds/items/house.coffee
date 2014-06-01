class mk.m11s.birds.House
  
  constructor : (@sname, @part, @assets) ->
    @view = new paper.Group()#@symbol.place()
    @view.transformContent = false
    @view.z = 0

    @sday = @assets[sname+'.svg']
    @snight = @assets[sname+'_night.svg']

    @view.addChild @sday.place()

    @view.scaling = 0.01
    # @view.scale 0.01

    @seed = sname
    weights = mk.helpers.getRandomWeights @part.joints, @seed
    @follower = new mk.helpers.PartFillFollower @view, @part, weights, rng(@seed) * 100 + 100

  show : (scale, delay) ->
    v = @view
    rdm = rng(@rdmk+'show') * 15
    tween = new TWEEN.Tween({ scale: 0.01 })
     .to({ scale: scale }, 1000)
     .delay(delay*(2650))
     .easing( TWEEN.Easing.Quadratic.Out )
     .onUpdate(->
        v.scaling = @scale
     ).start window.currentTime

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
     .onComplete(->
        v.removeChildren 0,1
     )
     .start window.currentTime

  update : ->
    @follower.update()