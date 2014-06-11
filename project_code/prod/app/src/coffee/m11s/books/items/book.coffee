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
    @h1 = true

  update : ->
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
  constructor: () ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0

    @path = new paper.Path.Rectangle [0, -40], [55, 75]
    @path.fillColor = mk.Scene::settings.getHexColor 'cream'
    @initBrightness = @path.fillColor.brightness
    @view.addChild @path

    @reset()
    @isGarde = false
    @isLocked = false

  update : ->
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

    for i in [0...5]
      p = new mk.m11s.books.Page()
      @view.addChild p.view
      @pages.unshift p

    @coverTop = new mk.m11s.books.Cover 'book_closed', 'book_open'
    @view.addChild @coverTop.view
    @pages.unshift @coverTop

    @pages[1].isGarde = true

    @currPage = 0
    @turnPageLock = 50
    
    @view.z = 0
    @view.transformContent = false
    @view.pivot = new paper.Point 20, 18
    @view.scale 1.5

    @handsPrevX = [@hands[0].x, @hands[1].x]

    @follower = new mk.helpers.JointFollower @view, @j, 200

  turnPage : (h) ->
    if @coverTop.isTurned
      for j in [1...@pages.length-2]
        if !@pages[j].isTurning
          console.log @pages[j].isGarde
          @pages[j].isTurning = true
          @turnPageLock = 0
          break
      if @turnPageCallback then @turnPageCallback h
    else
      @coverTop.isTurning = true

  update: ->
    @follower.update()

    for page in @pages
      if page.isTurning && !page.isLocked
        page.update()
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