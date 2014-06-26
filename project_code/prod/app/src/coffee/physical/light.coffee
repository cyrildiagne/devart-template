class mk.physical.DMXLight

  setup : (callback) ->
    @currDMXVal = 0
    @light = new ArtNetClient '192.168.16.122', 6454, =>
      console.log 'DMX light ready'
      @currDMXVal = 255
      @light.send [255]
      if callback then callback()

  fadeTo : (value, duration, callback) ->
    value = Math.floor value*255
    interval = setInterval =>
      d = (value - @currDMXVal)
      @currDMXVal += d * 0.05
      @light.send [Math.floor(@currDMXVal)]
      if Math.abs(d) < 1
        @currDMXVal = value
        clearInterval interval
        if callback then callback()
    , 30