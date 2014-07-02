class mk.m11s.books.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @book = null
    @cage = null
    @boat = null
    @waves = []
    delayed 1000, => @addHeadBook()
    @whale = null
    @numPagesTurned = 0

    @rock = new mk.m11s.books.Rock()
    @items.push @rock

    @isFlying = false

    # setBackgroundColor 'white'
    
    mouseDownCallbacks.push @onPageTurn if Config::DEBUG
    
  addHeadBook: () ->
    @getPart('head').view.visible = false
    hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @book = new mk.m11s.books.Book @joints[NiTE.HEAD], hands, @onPageTurn
    @items.push @book

  # clean : ->
  #   mouseDownCallbacks.splice @onPageTurn

  fly : ->
    @isFlying = true
    @addLines()

    @addStars()

    # @addWhale()
    # setInterval =>
    #   @whale.jump()
    # , 5000

  onPageTurn : (hand) =>
    # if hand then return
    # return
    @numPagesTurned++
    # console.log 'page turned : ' + @numPagesTurned
    
    if @numPagesTurned > 1
      @book.flyAway()

    switch @numPagesTurned
      when 1
        @addCage @joints[NiTE.LEFT_HAND]
      when 2
        @cage.switchLightOn()
      when 3
        @removeCage()
        @fly()
      # when 4,5,6,7,8,9
      #   @addWave() for i in [0...10]

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

  addLines : ->
    rightUpJnts  = @getJoints [ NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW, NiTE.RIGHT_HAND]
    leftUpJnts = @getJoints [ NiTE.LEFT_SHOULDER, NiTE.LEFT_ELBOW, NiTE.LEFT_HAND ]
    @upLines = new mk.m11s.books.LineWaves rightUpJnts, leftUpJnts, -9999
    @items.push @upLines

    # rightLowJnts = @getJoints [ NiTE.RIGHT_FOOT, NiTE.RIGHT_HIP, NiTE.RIGHT_HAND ]
    # leftLowJnts = @getJoints [ NiTE.LEFT_FOOT, NiTE.LEFT_HIP, NiTE.LEFT_HAND ]
    # @lowLines = new mk.m11s.books.LineWaves rightLowJnts, leftLowJnts, -3333
    # @items.push @lowLines

    return

    # leftHideJnts =  @getJoints [
    #   NiTE.LEFT_ELBOW
    #   NiTE.LEFT_SHOULDER
    #   NiTE.TORSO
    #   NiTE.LEFT_HAND
    # ]
    # leftHideShape = new mk.m11s.books.HideShape leftHideJnts
    # @items.push leftHideShape

    # leftHideJnts =  @getJoints [
    #   NiTE.TORSO
    #   NiTE.LEFT_HIP
    #   NiTE.LEFT_KNEE
    #   NiTE.LEFT_HAND
    # ]
    # leftHideShape = new mk.m11s.books.HideShape leftHideJnts
    # @items.push leftHideShape

    # rightHideJnts =  @getJoints [
    #   NiTE.RIGHT_ELBOW
    #   NiTE.RIGHT_SHOULDER
    #   NiTE.TORSO
    #   NiTE.RIGHT_HAND
    # ]
    # rightHideShape = new mk.m11s.books.HideShape rightHideJnts
    # @items.push rightHideShape

    # rightHideJnts =  @getJoints [
    #   NiTE.TORSO
    #   NiTE.RIGHT_HIP
    #   NiTE.RIGHT_KNEE
    #   NiTE.RIGHT_HAND
    # ]
    # rightHideShape = new mk.m11s.books.HideShape rightHideJnts
    # @items.push rightHideShape

    hideShape = new mk.m11s.books.HideShape @getJoints([NiTE.LEFT_HIP, NiTE.RIGHT_HIP, NiTE.LEFT_KNEE])
    @items.push hideShape
    hideShape = new mk.m11s.books.HideShape @getJoints([NiTE.RIGHT_HIP, NiTE.RIGHT_KNEE, NiTE.LEFT_KNEE])
    @items.push hideShape

    hideShape = new mk.m11s.books.HideShape @getJoints([NiTE.LEFT_KNEE, NiTE.RIGHT_KNEE, NiTE.LEFT_FOOT])
    @items.push hideShape
    hideShape = new mk.m11s.books.HideShape @getJoints([NiTE.RIGHT_KNEE, NiTE.RIGHT_FOOT, NiTE.LEFT_FOOT])
    @items.push hideShape

    # hideJnts =  @getJoints [
    #   NiTE.LEFT_KNEE
    #   NiTE.RIGHT_KNEE
    #   NiTE.RIGHT_FOOT
    #   NiTE.LEFT_FOOT
    # ]
    # hideShape = new mk.m11s.books.HideShape hideJnts
    # @items.push hideShape

  addBoat : ->

    @boat = 
      view : new paper.Group()
      update : -> #...

    side = if rng('boat') > 0.5 then 1 else -1

    @boat.view.addChild mk.Scene::assets['boat'].place()
    @boat.view.position.x = -(window.viewport.width+@boat.view.bounds.width)*0.5 * side
    @boat.view.scale(side, 1)
    @boat.view.z = -4000
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
    # @cage.switchLightOn()

  removeStars : ->
    @cage.switchLightOff()
    @stars.remove =>
      delayed 20, =>
        @stars.view.remove()
        @items.splice @items.indexOf(@stars),1