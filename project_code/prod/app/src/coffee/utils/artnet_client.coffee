#based on https://github.com/BrianMMcClain/artnet-node

class ArtNetClient

  constructor : (@address, @port, onReady) ->

    @available = false

    @HEADER   = [65, 114, 116, 45, 78, 101, 116, 0, 0, 80, 0, 14] # 0 - 11
    @SEQUENCE = [0] # 12
    @PHYSICAL = [0] # 13
    @UNIVERSE = [0, 0] # 14 - 15

    if chrome && chrome.sockets
      chrome.sockets.udp.create {}, (socketInfo) =>
        @socketId = socketInfo.socketId

        # address : Use "0.0.0.0" to accept packets from all local available network interfaces.
        # port : Use "0" to bind to a free port.
        chrome.sockets.udp.bind @socketId, "0.0.0.0", 0, (result) =>
          if result < 0
            console.log "Error binding socket: " + chrome.runtime.lastError.message
          else
            console.log "ArtNetClient - udp bound on 0.0.0.0 : 0"

        @available = true

        onReady()

  send : (data) =>

    if !@available then return

    # Calcualte the length
    length_upper = Math.floor data.length / 256
    length_lower = data.length % 256
    
    data = @HEADER
     .concat(@SEQUENCE)
     .concat(@PHYSICAL)
     .concat(@UNIVERSE)
     .concat([length_upper, length_lower])
     .concat(data)

    data = new Int8Array data
    
    chrome.sockets.udp.send @socketId, data.buffer, @address, @port, (result) ->
      if result.resultCode < 0
        console.log chrome.runtime.lastError.message

  close : () ->

    if !@available then return

    chrome.sockets.udp.close @socketId
