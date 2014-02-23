class SkeletonSync
  
  constructor : (@skeleton) ->
    @socket = null
    @reconnecting = false
    @onUserIn = null
    @onUserOut = null
    @onRatio = null
    @connect()

  connect : () ->
    @socket = new WebSocket 'ws://kikko.local:9092'
    @socket.binaryType = 'arraybuffer'
    @socket.onopen = @onSocketOpened
    @socket.onmessage = @onSocketMessage
    @socket.onclose = @onSocketClosed

  onSocketOpened : () =>
    console.log "websocket connected"

  onSocketClosed : () =>
    if !@reconnecting
      console.log "websocket disconnected"
    setTimeout(=>
      @connect()
    ,2000)
    @reconnecting = true

  onSocketMessage : (msg) =>
    if (msg.data instanceof ArrayBuffer)
       skeleton.data = new Float32Array( msg.data )
    else
      if msg.data is '/skeleton'
        #...
      else
        cmd = msg.data.split '/'
        cmd.shift()
        switch cmd[0]
          when 'user'
            if cmd[1] is 'in'
              if@onUserIn
                @onUserIn(cmd[2])
            else
              if @onUserOut
                @onUserOut(cmd[2])
          when 'ratio'
            if @onRatio
              @onRatio parseFloat(cmd[1])/parseFloat(cmd[2])
          else
            console.log msg.data
    