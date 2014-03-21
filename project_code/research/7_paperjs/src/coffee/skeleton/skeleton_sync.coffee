class mk.skeleton.SkeletonSync
  
  constructor : (@skeleton, @endpoint = 'local') ->
    @socket = null
    @reconnecting = false
    @onUserIn = null
    @onUserOut = null
    @onRatio = null
    @onDataUpdated = null

  connect : () ->
    if @endpoint is 'local'
      @socket = new WebSocket 'ws://kikko.local:9092'
      @socket.binaryType = 'arraybuffer'
      @socket.onopen = @onSocketOpened
      @socket.onclose = @onSocketClosed
      @socket.onmessage = (msg) =>
        @onSocketMessage(msg.data)
    else
      @socket = io.connect @endpoint
      @socket.on 'connect', @onSocketOpened
      @socket.on 'message', @onSocketMessage
      # @socket.on 'disconnect', @onSocketClosed
      @socket.on 'skeleton', (data) =>
        if data
          @skeleton.data = data
          if @onDataUpdated
            onDataUpdated()

  onSocketIOMessage : (data) =>
    # ab = new ArrayBuffer(data.length*2)
    # byteview = new Uint16Array ab
    # for i in [0...data.length]
    #   byteview[i] = data.charCodeAt[i]
    # floatview = new Float32Array ab
    # console.log (typeof data)
    console.log 'message'
    # skeleton.data = data
    # if @onDataUpdated
    #     onDataUpdated()
    # console.log floatview.length

  onSocketOpened : () =>
    console.log "websocket connected"

  onSocketClosed : () =>
    if !@reconnecting
      console.log "websocket disconnected"
    setTimeout(=>
      @connect()
    ,2000)
    @reconnecting = true

  onSocketMessage : (data) =>
    # console.log data
    # console.log( data instanceof Blob )
    # console.log( msg instanceof ArrayBuffer )
    # data = b64_buffer.decode data
    # data = new ArrayBuffer data
    # data = new Int8Array msg
    # console.log (data[0])
    # buf = new ArrayBuffer()
    # return
    if (data instanceof ArrayBuffer)
      @skeleton.data = new Float32Array( data )
      if @onDataUpdated
        onDataUpdated()
    else
      if data is '/skeleton'
        #...
      else
        cmd = data.split '/'
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
            console.log data
    