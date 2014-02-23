io = require('socket.io').listen(8080)

io.set 'log level', 2

position = {x:0, y:0}
viewports = {}

io.sockets.on 'connection', (socket) ->

  socket.emit 'id', socket.id
  socket.emit 'position', position
  for id, vp of viewports
    socket.emit 'viewport_enter', id, vp.x, vp.y, vp.width, vp.height

  socket.on 'viewport_enter', (id, x, y, width, height) ->
    viewports[id] = 
      x : x
      y : y
      width : width
      height : height
    io.sockets.emit 'viewport_enter', id, x, y, width, height

  socket.on 'viewport_move', (id, x, y) ->
    if !viewports[id] then return
    viewports[id].x = x
    viewports[id].y = y
    io.sockets.emit 'viewport_move', id, x, y

  socket.on 'viewport_resize', (id, width, height) ->
    if !viewports[id] then return
    viewports[id].width = width
    viewports[id].height = height
    io.sockets.emit 'viewport_resize', id, width, height

  socket.on 'blob_position', (pos) ->
    position = pos
    io.sockets.emit 'position', pos

  socket.on 'disconnect', () ->
    if viewports[socket.id]
      delete viewports[socket.id]
      io.sockets.emit 'viewport_exit', socket.id