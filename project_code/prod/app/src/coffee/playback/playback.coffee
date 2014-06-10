class mk.playback.Playback
  
  constructor : (@skeleton, @onComplete) ->
    @data = null
    @position = 0
    @numFrames = 0
    @nextFrameDeltaTime = 0
    @currDeltaTime = 0

  load : (@filepath, callback) ->

    dispatch 'loading:performance data'
    url = Config::replaysPath + '/' + @filepath
    console.log 'PLAYBACK > loading ' + url
    r = new XMLHttpRequest()
    r.open 'GET', url
    r.responseType = "arraybuffer"
    r.onload = () =>
      if r.status is 200
        @data = new Float32Array r.response
        @numFrames = @data.length / (3*15)
        console.log 'PLAYBACK > file loaded (' + @numFrames + ' frames)'
        @update 0

        arr = @filepath.split '_'
        if callback 
          callback arr[0], arr[2]
    r.send()

  update : (dt) ->
    @currDeltaTime += dt

    if @currDeltaTime >= @nextFrameDeltaTime
      begin = @position * 3 * 15
      sub = @data.subarray begin, begin + 3 * 15
      @skeleton.data = sub

      @currDeltaTime -= @nextFrameDeltaTime

      @nextFrameDeltaTime = 1000/30
      @position++
      if (@position > @numFrames)
        if @onComplete
          console.log 'PLAYBACK > complete'
          @onComplete()
        @position = 0