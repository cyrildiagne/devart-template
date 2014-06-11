class mk.m11s.books.BodyItems extends mk.m11s.base.BodyItems

  setupItems: () ->
    @addHeadBook()
    @cage = null
    
  addHeadBook: () ->
    hands = [@joints[NiTE.LEFT_HAND], @joints[NiTE.RIGHT_HAND]]
    @book = new mk.m11s.books.Book @joints[NiTE.HEAD], hands, @onPageTurn
    @items.push @book

  onPageTurn : (hand) =>
    if !@cage
      @addCage hand

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