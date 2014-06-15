class mk.m11s.lockers.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @flys = []
    @locks = []
    @addLockers()
    @addPile()

    @keyId = 0
    @lockId = 0

    @distMax = 20
    @distMax *= @distMax

    @timeSinceKey = -4000
    @timeBeforeNextKey = 0

  addLockers: ->
    symbs = ['locker1', 'locker2', 'locker3']
    parts = @getPartsExcluding ['head']
    rngk = 'addLockers'
    for p in parts
      for i in [1..5]
        chance = 0.4
        if p.name is "torso"
          chance = 1
        if rng(rngk) < chance
          symbol = @assets.symbols.lockers[symbs.seedRandom(rngk)]
          lock = new mk.m11s.lockers.Lock symbol, p, 'Lockers'+@items.length
          @locks.push lock
          @items.push lock

  addKey: ->
    key = new mk.m11s.lockers.Key @flys.length
    @items.push key
    @flys.push key

  addPile: ->
    sym = @assets.symbols.lockers['pile']
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

    for i in [@flys.length-1..0] by -1
      fly = @flys[i]
      lock = @getKeyInLock fly
      if lock
        fly.view.position = new paper.Point 0, -10 * lock.item.scaling.y
        lock.available = false
        @turnKeyAnimation fly.view
        lock.breakFree()
        @pile.addSome()
      if lock || fly.view.position.x > 500
        fly.clean()
        @items.splice @items.indexOf(fly),1
        @flys.splice i,1
        if lock
          lock.view.addChild fly.view

    for i in [@locks.length-1..0] by -1
      l = @locks[i]
      if l.out
        l.clean()
        @items.splice @items.indexOf(l),1
        @locks.splice i,1

    @timeSinceKey+=dt
    if @flys.length < 10 and @timeSinceKey > @timeBeforeNextKey
      @timeSinceKey -= @timeBeforeNextKey
      @timeBeforeNextKey = rng('LockersUpdate') * 3000 + 2000
      @addKey()
    
    