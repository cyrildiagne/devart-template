class mk.skeleton.SkeletonSync
  
  constructor : (@skeleton, @port) ->
    @socketId = -1

    @oscParser = null
    @data = null

    @hasNewData = false

    @bMinOneUser = false
    @bTimeoutForComeback = -1

    @onFirstUserIn = null
    @onLastUserOut = null
    @onRatio       = null
    @onDataUpdated = null

  connect : (forceSocketUse=false) ->
    if chrome && chrome.sockets && !forceSocketUse
      @connectUDP()
    else
      @connectLocalServer()


# --------------------------------------------
# MODE 1 - Chrome App + Windows
# CHROME APP <-- UDP(OSC) <-- WINDOWS + KINECT
# --------------------------------------------

  connectUDP : () ->
    @oscParser = new OSCParser()
    udp = chrome.sockets.udp
    udp.create {}, (socketInfo) =>
      @socketId = socketInfo.socketId
      udp.onReceive.addListener @onUDPReceive
      udp.bind @socketId, '0.0.0.0', @port, (result) =>
        if result < 0
          console.log "SkeletonSync - Error binding socket."
          console.log chrome.runtime.lastError
          return
        else
          console.log "SkeletonSync - udp listening on port " + @port

  onUDPReceive : (info) =>
    if (info.socketId != @socketId)
      return
    setTimeout () => # get out of udp event thread to get error messages
      @oscParser.parse info.data, 0, (msg) =>
        switch msg.path
          when '/skeleton'
            if !@bMinOneUser
              @bMinOneUser = true
              if @onFirstUserIn then @onFirstUserIn()
            @data = msg.params
            @hasNewData = true
            if @onDataUpdated
              onDataUpdated()
            break
          when '/first_user_entered'
            if @bTimeoutForComeback > -1
              clearTimeout @bTimeoutForComeback
              @bTimeoutForComeback = -1
            else
              if !@bMinOneUser
                @bMinOneUser = true
                if @onFirstUserIn then @onFirstUserIn()
          when '/last_user_left'
            if @onLastUserOut
              @bTimeoutForComeback = setTimeout =>
                @bMinOneUser = false
                @onLastUserOut()
              , 5000
          else
            console.log msg
    , 1

  close : (callback) =>
    chrome.sockets.udp.close @socketId, callback

# ----------------------------------------------------------
# MODE 2 - Browser + NodeJS
# WEB BROWSER <-- SOCKET <-- LOCAL NODEJS <-- FILE STREAMING
# ----------------------------------------------------------

  connectLocalServer : () ->
    @socket = io.connect '127.0.0.1:'+@port
    @socket.on 'connect', @onSocketOpened
    @socket.on 'message', @onSocketMessage
    # @socket.on 'disconnect', @onSocketClosed
    @socket.on 'skeleton', (data) =>
      if data
        @data = new Float32Array(data)
        @hasNewData = true
        if @onDataUpdated
          onDataUpdated()

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
  #   