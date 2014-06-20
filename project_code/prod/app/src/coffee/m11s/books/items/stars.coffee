class mk.m11s.books.Stars
  
  constructor : (@head) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = -3000

    @height = window.viewport.height*0.5
    @offset = -window.viewport.height*0.25

    @path = new paper.Path.Circle
      center : [0,0]
      radius : 4
      fillColor : 'white'

    @symbol = new paper.Symbol @path
    for i in [0...40]
      center = 
        x : (rng('stars')-0.5) * window.viewport.width
        y : -window.viewport.height * 0.5
      item = @symbol.place(center)
      item.dy = (rng('stars')-0.5) * @height + @offset
      item.z = rng('stars') * 20 + 5
      item.scaling = 0.2 + item.z / 25
      @view.addChild item

  update : (dt) ->
    hDist =  - @head.x / (window.viewport.width * 0.5)
    # if hDist < 0 then hDist -= 1
    # else hDist += 1
    w2 = window.viewport.width * 0.5
    for s in @view.children
      s.position.y += (s.dy-s.position.y) * 0.001 * dt
      s.position.x += s.z * hDist * 0.05
      if s.position.x > w2
        s.position.x = - w2
      else if s.position.x < -w2
        s.position.x = w2

  remove : (callback) ->
    dy = -window.viewport.height*0.5 - 100
    s.dy = dy for s in @view.children
    delayed 2000, callback
