class mk.playback.Playback
  
  constructor : (@skeleton) ->
    @data = null
    @position = 0
    @numFrames = 0
    @nextFrameDeltaTime = 0
    @currDeltaTime = 0

  load : (@filepath, callback) ->
    r = new XMLHttpRequest()
    r.open("GET", @filepath)
    r.responseType = "arraybuffer"
    r.onload = () =>
      if r.status is 200
        @data = new Float32Array r.response
        @numFrames = @data.length / (3*15)
        console.log 'PLAYBACK > ' + @filepath + ' loaded (' + @numFrames + ' frames)'
        @update 0
        if callback then callback()
    r.send()

  update : (dt) ->
    @currDeltaTime += dt

    if @currDeltaTime >= @nextFrameDeltaTime
      begin = @position * 3 * 15
      sub = @data.subarray begin, begin + 3 * 15
      @skeleton.data = sub

      @currDeltaTime -= @nextFrameDeltaTime

      @nextFrameDeltaTime = 1/30
      @position++
      if (@position > @numFrames)
        @position = 0