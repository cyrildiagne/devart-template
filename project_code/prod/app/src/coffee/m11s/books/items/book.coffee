class mk.m11s.books.Cover
  constructor: (@s1, @s2) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0

    @recto = mk.Scene::assets[@s1].place()
    @recto.position.x = @recto.bounds.width * 0.5
    @view.addChild @recto

    @verso = mk.Scene::assets[@s2].place()
    @verso.position.x = @verso.bounds.width * 0.5
    @verso.visible = false
    @view.addChild @verso

    @isTurning = false
    @isTurned = false
    @isCover = true
    @h1 = true

  update : ->
    if @isTurning && !@isLocked
      @updateTurn()

  updateTurn : ->
    if @h1
      @view.matrix.a -= 0.03
      @view.matrix.c -= 0.015
      if @view.matrix.a < 0.03
        @h1 = false
        @verso.visible = true
        @recto.visible = false
    else 
      @justReachedH2 = false
      @view.matrix.a -= 0.03
      @view.matrix.c += 0.015
      if @view.matrix.a < -0.95
        @isTurning = false
        @isTurned = true
        return



class mk.m11s.books.Page
  constructor: (w, h) ->
    @w = w
    @h = h

    hvec = [w*0.5, 0]
    vvec = [0, h*0.5]

    @path = new paper.Path()
    @path.transformContent = false
    @path.segments = [
      [[0, 0], null, hvec]
      [[w, 0], null, vvec]
      [[w, h], null, null]
      [[0, h], hvec, null]
      [[0, 0], vvec, null]
    ]
    @path.fillColor = mk.Scene::settings.getHexColor 'cream'
    @initBrightness = @path.fillColor.brightness

    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.addChild @path

    @reset()
    @isGarde   = false
    @isLocked  = false
    @isTurning = false
    @isFlying  = false

  verticalBend : (bend) ->
    scale = 1 - bend
    bend = bend * @h * 0.5
    @path.segments[1].handleOut.x = -bend
    @path.segments[4].handleIn.x = -bend
    @path.scaling = [@path.scaling.x, 0.75+scale*0.25]

  horizontalBend : (bend) ->
    scale = 1 - bend
    bend = bend * @w * 0.5
    @path.segments[0].handleOut.y = -bend
    @path.segments[3].handleIn.y = -bend
    @path.scaling = [0.75+scale*0.25, @path.scaling.y]

  flyAway : (delay, onCompleteCallback) ->
    @isLocked = true
    @isFlying = true

    v = @view
    p = @
    tween = new TWEEN.Tween({x:1, y:-0.5, vbend : 0, hbend : 0})
    #.to({ x: window.viewport.width * (rng('page')-0.5), y: -window.viewport.height*0.6 }, 2000)
    .to(
      x : 10+rng('flyaway')*25
      y : -8-rng('flyaway')*15
      vbend : Math.random()
      hbend : Math.random()
      rotation : 45 + Math.random() * 125
    , 1500)
    .delay(delay)
    .easing( TWEEN.Easing.Quadratic.In )
    .onUpdate(->
      p.verticalBend @vbend
      p.horizontalBend @hbend
      v.rotation = @rotation
      v.position.x += @x
      v.position.y += @y
    )
    .onComplete(->
      if onCompleteCallback then onCompleteCallback()
    ).start window.currentTime

  update : ->
    if @isTurning && !@isLocked
      @updateTurn()
    else if @isFlying
      @view.position.y -= 1

  updateTurn : ->
    if @h1
      @view.matrix.a -= 0.03
      @view.matrix.c -= 0.015
      if @view.matrix.a < 0.03
        @h1 = false
        @justReachedH2 = true
    else 
      @justReachedH2 = false
      @view.matrix.a -= 0.03
      @view.matrix.c += 0.015
      if @view.matrix.a < -0.85
        if !@isGarde
          @reset()
        else
          @isLocked = true
    if @isTurning
      @path.fillColor.brightness = (0.7 + Math.abs(@view.matrix.a)*0.3)*@initBrightness

  reset : ->
    @view.matrix.a = 0.9
    @view.matrix.c = -0.15
    @h1 = true
    @isTurning = false
    @justReachedH2 = false




class mk.m11s.books.Book

  constructor: (@j, @hands, @turnPageCallback) ->

    @rngk = 'book'

    @view = new paper.Group()
    
    @pages =[]

    @coverBottom = new mk.m11s.books.Cover 'book_open', 'book_closed'
    @view.addChild @coverBottom.view
    @pages.unshift @coverBottom

    @coverTop = new mk.m11s.books.Cover 'book_closed', 'book_open'
    @view.addChild @coverTop.view
    @pages.unshift @coverTop

    p = new mk.m11s.books.Page(55, 75)
    p.view.position.y = -40
    p.isGarde = true
    @pages.splice 1,0,p
    @view.insertChild 1, p.view

    @addPage() for i in [0...5]

    @currPage = 0
    @turnPageLock = 100
    
    @view.z = 0
    @view.transformContent = false
    @view.pivot = new paper.Point 20, 18
    @view.scale 1.5

    @handsPrevX = [@hands[0].x, @hands[1].x]

    @follower = new mk.helpers.JointFollower @view, @j, 200

  addPage : () ->
    p = new mk.m11s.books.Page(55, 75)
    p.view.position.y = -40
    @view.insertChild 2, p.view
    @pages.splice 2,0,p

  turnPage : (h) ->
    if @coverTop.isTurned
      for j in [1...@pages.length-2]
        if !@pages[j].isTurning
          @pages[j].isTurning = true
          @turnPageLock = 0
          if @turnPageCallback then @turnPageCallback h
          break
    else
      @coverTop.isTurning = true

  flyAway : (num=2)->
    curr = 0
    for i in [@pages.length-3..1]
      p = @pages[i]
      if !p.isCover
        do (p, curr) =>
          # setTimeout( =>
          #   p.view.z = 9999
          #   p.view.scaling = 1.5
          #   p.view.position.x += @view.position.x
          #   p.view.position.y += @view.position.y - 40
          #   @view.parent.addChild(p.view)
          # , 1000)
          p.flyAway curr*300, ->
            p.view.remove()
        @addPage()
        @pages.splice @pages.indexOf(p),1
        if ++curr >= num
          return

  update: ->
    @follower.update()

    for page in @pages
      page.update()
      if page.isTurning && !page.isLocked
        if page is @coverTop
          @view.pivot = new paper.Point( 20 - (1-page.view.matrix.a) * 12, 18)
        else if page is @coverBottom
          @view.pivot = new paper.Point( - (1-page.view.matrix.a) * 20, 18)
        else if page.justReachedH2
          page.view.bringToFront()

    @turnPageLock++
    i = 0
    for h in @hands
      dx = h.x-@j.x
      dy = h.y-@j.y
      dist = (dx*dx + dy*dy)
      if dist < 100*100 and (h.x-@handsPrevX[i]) < -2
        if @turnPageLock > 50
          @turnPage h
      @handsPrevX[i] = h.x
      i++