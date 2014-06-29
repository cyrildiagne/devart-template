class mk.m11s.lockers.BodyItems extends mk.m11s.base.BodyItems

  setupItems : () ->
    @flys = []

    @locks = []
    @addLockers()

    # delayed 1000, => @flyPile 2

    # @doors = []
    @door = null
    # @addDoor()
    @numDoorOpen = 0

    @keyId = 0
    @lockId = 0

    @distMax = 20
    @distMax *= @distMax

    @timeSinceKey = -4000
    @timeBeforeNextKey = 0

    # @pilesCanFly = false

    @MODE_NOTHING = -1
    @MODE_PILE = 0
    @MODE_DOORS = 1
    @MODE_INSIDE = 2
    @currMode = @MODE_NOTHING

    @setModePile()
    # @setModeInside()

  onMusicEvent : (evId) ->
    
    switch evId
      # when 1
        # @pilesCanFly = true
      when 3
        @currMode = @MODE_NOTHING
        while @piles.length
          @piles.shift().fly()
        delayed 2000, =>
          @addDoor()
          @currMode = @MODE_DOORS
          @onUnlock()
      # when 5
      #   @setModeInside()
        # @pilesCanFly = true
        # @flyInterval()
        # @scaleFactor = 0.1
        # for pile in @piles
        #   scaling = mk.m11s.lockers.Pile::SCALE_MAX_BEFORE_FLY
        #   if pile.pile.scaling.x > scaling
        #     @flyPile pile.type

  setModePile : ->
    @piles = []
    @addPile type for type in [0...3]
    @currMode = @MODE_PILE

  setModeInside : ->
    @addDoor() if !@door
    @door.setupInside()
    @currMode = @MODE_INSIDE

  addDoor : ->
    @door = new mk.m11s.lockers.DoorOpen @joints[NiTE.HEAD], @doorAnimComplete
    @items.push @door

  doorAnimComplete : (d) =>
    console.log 'anim complete'

  removeDoor : ->
    setTimeout =>
      @items.splice @items.indexOf(d),1
      d.clean()
    , 1

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
    asset = null
    if @currMode is @MODE_INSIDE then asset = 'key2'
    key = new mk.m11s.lockers.Key @flys.length, asset
    @items.push key
    @flys.push key

  getBiggestPile : ->
    if !@piles.length then return null
    biggest = @piles[0]
    for p in @piles
      if p.pile.scaling.x > biggest.pile.scaling.x
        biggest = p
    return biggest

  addPile : (type) ->
    pile = new mk.m11s.lockers.Pile type
    pile.fullCallback = @pileFullCallback
    @items.push pile
    @piles.splice type, 0, pile

  pileFullCallback : (pile) =>
    if @currMode is @MODE_PILE
      @flyPile pile.type

  flyPile : (type, add=true) ->
    # if !@pilesCanFly then return
    @piles[type].fly()
    @piles.splice type, 1
    @addPile type if add

  flyInterval : =>
    p = @getBiggestPile()
    if p
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

  onUnlock : (fly, lock) ->
    switch @currMode
      when @MODE_PILE
        @piles[lock.type].addSome()
      when @MODE_DOORS
        @numDoorOpen++
        if @numDoorOpen > 3
          @setModeInside()
        else
          @door.popupAndShineYouBeautiful()
      when @MODE_INSIDE
        @door.addParticlesTime += 3000

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
            @onUnlock fly, lock
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
    
    