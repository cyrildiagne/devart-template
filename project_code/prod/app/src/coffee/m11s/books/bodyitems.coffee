class mk.m11s.books.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @getPart('head').view.visible = false
    @book = null
    @cage = null
    @boat = null
    @waves = []
    delayed 1000, => @addHeadBook()
    @whale = null
    @numPagesTurned = 0
    @addWhale()
    
    mouseDownCallbacks.push @onPageTurn if Config::DEBUG
    
  addHeadBook: () ->
    hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @book = new mk.m11s.books.Book @joints[NiTE.HEAD], hands, @onPageTurn
    @items.push @book

  # clean : ->
  #   mouseDownCallbacks.splice @onPageTurn

  onPageTurn : (hand) =>
    # if hand then return
    @numPagesTurned++
    console.log 'page turned : ' + @numPagesTurned
    
    if @numPagesTurned < 2 and !@cage
      @addCage @joints[NiTE.LEFT_HAND]#hand
      return
    
    if rng('pageturn') > 0.5
      @book.flyAway()

    if @whale
      for i in [0...12]
        @addWave()
      @addBoat() if !@boat
      if @numPagesTurned > 3 then @whale.jump()
      return

    if !@stars
      @addStars()
      return

    # if @numPagesTurned is 3
    #   @removeStars()
    #   return

  addCage : (hand) ->
    h = @joints[NiTE.LEFT_HAND]
    if hand is h
      h = @joints[NiTE.RIGHT_HAND]
    @cage = new mk.m11s.books.Cage h
    @items.push @cage

  removeCage : ->
    @cage.remove =>
      delayed 20, =>
        @cage.view.remove()
        @items.splice @items.indexOf(@cage),1
        @cage = null

  addBoat : ->

    @boat = 
      view : new paper.Group()
      update : -> #...

    side = if rng('boat') > 0.5 then 1 else -1

    @boat.view.addChild mk.Scene::assets['boat'].place()
    @boat.view.position.x = -(window.viewport.width+@boat.view.bounds.width)*0.5 * side
    @boat.view.scale(side, 1)
    @boat.view.z = -3000
    @boat.view.transformContent = false

    dt = 0

    tween = new TWEEN.Tween(@boat.view.position)
    .to({ x: (window.viewport.width+@boat.view.bounds.width)*0.5*side }, 5000)
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

  addWhale : ->
    @whale = new mk.m11s.books.Whale =>
      console.log 'whale done'
      w = @whale
      @whale = null
      delayed 20, =>
        w.view.remove()
        @items.splice @items.indexOf(w),1
    @items.push @whale

  addStars : () ->
    @stars = new mk.m11s.books.Stars @joints[NiTE.HEAD]
    @items.push @stars
    @cage.switchLightOn()

  removeStars : ->
    @cage.switchLightOff()
    @stars.remove =>
      delayed 20, =>
        @stars.view.remove()
        @items.splice @items.indexOf(@stars),1