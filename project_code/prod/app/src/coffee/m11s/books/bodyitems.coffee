class mk.m11s.books.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @book = null
    @cage = null
    @boat = null
    @waves = []
    delayed 1000, => @addHeadBook()
    
  addHeadBook: () ->
    hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @book = new mk.m11s.books.Book @joints[NiTE.HEAD], hands, @onPageTurn
    @items.push @book

  onPageTurn : (hand) =>
    if !@cage
      @addCage hand
    else
      if rng('pageturn') > 0.5
        @book.flyAway()
      if !@boat
        @addBoat()
      else
        for i in [0...12]
          @addWave()

  addCage : (hand) ->
    symbol = mk.Scene::assets['cage']
    h = @joints[NiTE.LEFT_HAND]
    if hand is h
      h = @joints[NiTE.RIGHT_HAND]
    @cage = new mk.helpers.SimpleJointItem symbol, h, 200
    @cage.view.pivot = new paper.Point 0, -@cage.view.bounds.width*0.5 - 20
    @cage.view.scale 0.01
    @items.push @cage

    v = @cage.view
    tween = new TWEEN.Tween({ scale: 0.01 })
     .to({ scale: 1 }, 1000)
     .onUpdate(->
        v.scaling = @scale
     )
     .start window.currentTime

  addBoat : ->

    @boat = 
      view : new paper.Group()
      update : -> #...

    side = if rng('boat') > 0.5 then 1 else -1

    @boat.view.addChild mk.Scene::assets['boat'].place()
    @boat.view.position.x = -(window.viewport.width+@boat.view.bounds.width)*0.5 * side
    @boat.view.scale(side, 1)
    @boat.view.z = -2000
    @boat.view.transformContent = false

    dt = 0

    tween = new TWEEN.Tween(@boat.view.position)
    .to({ x: (window.viewport.width+@boat.view.bounds.width)*0.5*side }, 10000)
    .onUpdate(=>
      dt++
      @boat.view.rotation = Math.sin(dt*0.04) * 5 * side
      @boat.view.position.y = -Math.cos(dt*0.04) * 10
    )
    .onComplete(=>
      @boat.view.remove()
      @items.splice @items.indexOf(@boat,1),1
      @boat = null
    ).start window.currentTime

    @items.push @boat

  addWave : ->
    wave = new mk.m11s.books.Wave =>
      wave.view.remove()
      @waves.splice @waves.indexOf(wave),1
      @items.splice @items.indexOf(wave),1
    @waves.push wave
    @items.push wave