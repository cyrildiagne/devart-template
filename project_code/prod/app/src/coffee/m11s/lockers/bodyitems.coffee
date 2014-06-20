class mk.m11s.lockers.BodyItems extends mk.m11s.base.BodyItems

  setupItems : () ->
    @flys = []

    @locks = []
    @addLockers()

    @piles = []
    @addPile type for type in [0...3]
    # delayed 1000, => @flyPile 2

    @keyId = 0
    @lockId = 0

    @distMax = 20
    @distMax *= @distMax

    @timeSinceKey = -4000
    @timeBeforeNextKey = 0

    @pilesCanFly = false

  onMusicEvent : (evId) ->
    switch evId
      when 4
        @pilesCanFly = true
        @flyInterval()
        @scaleFactor = 0.1
        # for pile in @piles
        #   scaling = mk.m11s.lockers.Pile::SCALE_MAX_BEFORE_FLY
        #   if pile.pile.scaling.x > scaling
        #     @flyPile pile.type

  addLockers : ->
    parts = @getPartsExcluding ['head']
    rngk = 'addLockers'
    for p in parts
      max = 3
      if p.name is "torso"
        max = 6
      for i in [1..max]
        type = rngi(rngk,0,2)
        lock = new mk.m11s.lockers.Lock type, p, 'Lockers'+@items.length
        @locks.push lock
        @items.push lock
    lock = new mk.m11s.lockers.Lock 0, @getPart('head'), 'Lockers'+@items.length
    @locks.push lock
    @items.push lock

  addKey : ->
    key = new mk.m11s.lockers.Key @flys.length
    @items.push key
    @flys.push key

  getBiggestPile : ->
    if !@piles.length then return
    biggest = @piles[0]
    for p in @piles
      if p.pile.scaling.x > biggest.pile.scaling.x
        biggest = p
    return biggest

  addPile : (type) ->
    console.log 'add pile'
    pile = new mk.m11s.lockers.Pile type
    # pile.fullCallback = => @flyPile pile.type
    @items.push pile
    @piles.splice type, 0, pile

  flyPile : (type) ->
    if !@pilesCanFly then return
    @piles[type].fly()
    @piles.splice type, 1
    @addPile type

  flyInterval : =>
    p = @getBiggestPile()
    @flyPile(p.type)
    delayed 4080, @flyInterval

  getKeyInLock : (fly) ->
    for lock in @locks
      if !lock.available then continue
      d = fly.view.position.getDistance lock.view.position, true
      if d < @distMax
        diff = lock.item.scaling.y-fly.view.scaling.y
        if diff < 0.8 and diff > -0.8
          return lock
    return null

  update : (dt) ->
    super dt

    for i in [@flys.length-1..0] by -1
      fly = @flys[i]
      lock = @getKeyInLock fly
      if lock
        fly.view.position = new paper.Point 0, -10 * lock.item.scaling.y
        lock.available = false
        do (fly, lock) =>
          fly.turn =>
            lock.breakFree()
            @piles[lock.type].addSome()
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
      @timeBeforeNextKey = rng('LockersUpdate') * 3000 + 3000
      @addKey()
    
    