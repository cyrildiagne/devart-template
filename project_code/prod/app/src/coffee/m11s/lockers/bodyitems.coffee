class mk.m11s.lockers.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @flys = []
    @locks = []
    @addLockers()
    @addPile()

    @distMax = 30
    @distMax *= @distMax

    @timeSinceKey = 0
    @timeBeforeNextKey = 0

  addLockers: ->
    symbs = ['locker1.svg', 'locker2.svg', 'locker3.svg']
    parts = @getPartsExcluding ['head']
    rngk = 'addLockers'
    for p in parts
      for i in [1..3]
        chance = 0.5
        if p.name is "torso"
          chance = 1
        if rng(rngk) < chance
          symbol = @assets.symbols.lockers[symbs.seedRandom(rngk)]
          lock = new mk.m11s.lockers.Lock symbol, p, 'Lockers'+@items.length
          @locks.push lock
          @items.push lock

  addKey: ->
    rngk = 'addKey'
    asset = ['key1.svg', 'key2.svg'].seedRandom rngk
    symbol = @assets.symbols.lockers[asset]
    item = symbol.place()
    item.pivot = new paper.Point 0, 0
    fly = new mk.helpers.Flying item, @items.length,
      color1 : '#' + @settings.palette.cream.toString 16
      color2 : '#' + @settings.palette.lightRed.toString 16
      wingWidth : 350
      wingHeight : 0
      velocity : new paper.Point 3+rng(rngk)*2, 0
      wingSpeed : 0.7
      pos : new paper.Point -400, (rng(rngk)-0.5) * 800 - 50
    fly.view.scaling = rng(rngk)*0.2 + 0.8
    fly.view.pivot = new paper.Point item.bounds.width*0.5,0
    @items.push fly
    @flys.push fly

  addPile: ->
    sym = @assets.symbols.lockers['pile.svg']
    @pile = new mk.m11s.lockers.Pile sym, @settings.palette.lightRed
    @items.push @pile

  getKeyInLock : (fly) ->
    for lock in @locks
      if !lock.available then continue
      d = fly.view.position.getDistance lock.view.position, true
      if d < @distMax
        diff = lock.item.scaling.y-fly.view.scaling.y
        if diff < 0.8 and diff > -0.8
          return lock
    return null

  turnKeyAnimation : (keyView) ->
    # tween = new TWEEN.Tween( { x : 0 } )
    #  .to( { x: 20 }, 500 )
    #  .easing( TWEEN.Easing.Quadratic.Out )
    #  .onUpdate( ->
    #     keyView.position.x = @x
    #  )
    #  .onComplete( ->
    #     tween = new TWEEN.Tween( { scale: keyView.scaling.y } )
    #      .to( { scale: keyView.scaling.y * 0.5 }, 500 )
    #      .onUpdate( ->
    #         keyView.scaling = new paper.Point keyView.scaling.x, @scale
    #      ).start()
    #  ).start()    

  update: (dt) ->
    super dt
    stopArr = []

    for fly in @flys
      lock = @getKeyInLock fly
      if lock
        stopArr.push fly
        fly.view.position = new paper.Point 0, -10 * lock.item.scaling.y
        fly.view.remove()
        lock.view.addChild fly.view
        lock.available = false
        @turnKeyAnimation fly.view
        lock.breakFree()
        @pile.addSome()
      else if fly.view.position.x > 500
        stopArr.push fly
        fly.view.remove()

    for f in stopArr
      f.stop()
      @flys.splice @flys.indexOf(f),1
      @items.splice @items.indexOf(f),1

    rmLocks = []
    for l in @locks
      if l.out
        l.clean()
        rmLocks.push l
    for l in rmLocks
      i = @items.indexOf(l)
      @locks.splice @locks.indexOf(l),1
      @items.splice @items.indexOf(l),1

    @timeSinceKey+=dt
    if @flys.length < 5 and @timeSinceKey > @timeBeforeNextKey
      @timeSinceKey -= @timeBeforeNextKey
      @timeBeforeNextKey = rng('LockersUpdate') * 3000 + 2000
      @addKey()
    
    