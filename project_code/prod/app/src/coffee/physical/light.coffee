class mk.physical.DMXLight

  setup : (callback) ->
    @currDMXVal = 0
    @interval = -1
    @timeout = -1
    @light = new ArtNetClient '192.168.16.122', 6454, =>
      console.log 'DMX light ready'
      @currDMXVal = 255
      @light.send [255]
      if callback then callback()

  fadeTo : (value, duration, callback) ->
    value = Math.floor value*255
    @stopPulseAnimation()
    @interval = setInterval =>
      d = (value - @currDMXVal)
      @currDMXVal += d * 0.05
      @light.send [Math.floor(@currDMXVal)]
      if Math.abs(d) < 1
        @currDMXVal = value
        clearInterval @interval
        if callback then callback()
    , 30

  fadeToSpeed : (value, speed, callback) ->
    value = Math.floor value*255
    @stopPulseAnimation()
    @interval = setInterval =>
      d = (value - @currDMXVal)
      @currDMXVal += d * speed
      @light.send [Math.floor(@currDMXVal)]
      if Math.abs(d) < 1
        @currDMXVal = value
        clearInterval @interval
        if callback then callback()
    , 30

  startPulseAnimation : =>
    halo = document.getElementById 'halo'
    halo.style.opacity = 0
    @timeout = setTimeout(=>
      @fadeToSpeed 1, 0.2, =>
        @fadeToSpeed 0.2, 0.4, =>
          @fadeToSpeed 1, 0.3, =>
            @fadeToSpeed 0, 0.2, =>
              halo.style.opacity = 1
              @timeout = setTimeout(=>
                @startPulseAnimation()
              , 4000)
    , 1000)

  stopPulseAnimation : =>
    clearInterval @interval
    clearTimeout @timeout
    halo.style.opacity = 0
    if @tween then @tween.stop()