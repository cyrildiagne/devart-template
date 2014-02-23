class Viewport

  constructor : (x, y, width, height) ->
    @view = new PIXI.Graphics()
    @dx = @dy = 0
    @move x, y
    @setSize width, height

  setSize : (width, height) ->
    @width = width
    @height = height
    @redraw()

  move : (x, y) ->
    @dx = x
    @dy = y

  update : () ->
    @view.x += (@dx - @view.x) * 0.1
    @view.y += (@dy - @view.y) * 0.1

  redraw : () ->
    @view.clear()
    @view.lineStyle(3, 0xcccccc, 0.5)
    @view.beginFill(0xcccccc, 0.1)
    @view.drawRect(0, 0, @width, @height)


class Viewports

  constructor : () ->
    @vps = {}
    @view = new PIXI.DisplayObjectContainer()

  update : () ->
    for id, vp of @vps
      @vps[id].update()

  add : (id, x, y, width, height) ->
    @vps[id] = new Viewport(x, y, width, height)
    @view.addChild @vps[id].view

  move : (id, x, y) ->
    if !@vps[id] then return
    @vps[id].move x, y

  resize : (id, width, height) ->
    if !@vps[id] then return
    @vps[id].setSize width, height

  remove : (id) ->
    if !@vps[id] then return
    @view.removeChild(@vps[id].view)
    delete @vps[id]

