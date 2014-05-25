# FILE DEPRECATED
# NOW LOADING DATA DIRECTLY FROM THE WEB APP

fs = require 'fs'
{Buffer} = require 'buffer'
io = require 'socket.io'

port = 7000
buffer = new Buffer 180 # 15 joints * 3 axis * 4 bytes
server = null
file_data = null
file_position = 0
current_pose = null
interval = null
connectCounter = 0

setup_server = () ->
  server = io.listen port
  server.set 'log level', 2
  server.set 'origins', 'kikko.fr:*, localhost:*, kikko.local:*'
  server.on 'connection', on_user_connected
  console.log "listening on port #{port}"

on_user_connected = (socket) ->
  socket.on 'disconnect', on_user_disconnected
  socket.send '/ratio/640/480'
  socket.send '/user/in/0'
  socket.emit('skeleton', current_pose)
  if connectCounter is 0
    start_broadcast()
  connectCounter++

on_user_disconnected = (socket) ->
  connectCounter--
  if connectCounter is 0
    stop_broadcast()

broadcast_next_pose = () ->
  fs.read file_data, buffer, 0, 180, file_position, (err, num) ->
    if err
      console.log err
      return
    if num == 0
      file_position = 0
    else
      file_position += 180
      current_pose = get_floatarray buffer
      for id,socket of server.sockets.sockets
        socket.emit('skeleton', current_pose)

# until socket.io properly handles binary communication
get_floatarray = (buffer) ->
  ab = new ArrayBuffer(buffer.length)
  byteview = new Uint8Array ab
  for i in [0...buffer.length]
    byteview[i] = buffer[i]
  floatview = new Float32Array ab
  arr = []
  for i in [0...floatview.length]
    arr[i] = floatview[i]

start_broadcast = ->
  file_position = 0
  if interval is null
    interval = setInterval broadcast_next_pose, 1000/30
    console.log 'broadcast started'

stop_broadcast = ->
  if interval isnt null
    clearInterval interval
    interval = null
    console.log 'broadcast stopped'

fs.open 'output.bin', 'r', (status, data) ->
  if status
    console.log status.message
    return
  file_data = data
  setup_server()
  