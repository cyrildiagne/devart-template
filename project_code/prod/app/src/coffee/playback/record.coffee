class mk.playback.Record

  constructor : () ->
    @durationMaxSeconds = 180
    @reset()

  reset : () ->
    @skeletonDatas = new Float32Array 30*@durationMaxSeconds*15*3 # fps * seconds_max * numjoints * axis
    @position = 0
    @length = 0
    @currDeltaTime = 0
    @isRecording = false

  begin : (@info) ->
    if @isRecording
      @reset()
    @isRecording = true

  end : () ->
    @info.duration = new Date() - @info.timestamp
    name = @info.timestamp + '_' + ('000'+@info.duration).slice(-6) + '_' + @info.m11
    @saveFrameDatas name, @skeletonDatas.subarray 0, @length
    @reset()

  saveFrameDatas : (name, data) ->
    console.log 'saving ' + name + ' - length: '+data.length

    if chrome && chrome.fileSystem
      config = 
        type: 'saveFile'
        suggestedName: name
      chrome.fileSystem.chooseEntry config, (writableEntry) =>
        writableEntry.createWriter (writer) =>
          writer.onerror = (err) ->
            console.log 'ERROR '
            console.log err
          writer.onwriteend = =>
            console.log 'File saved'
            @saveComplete()
          blob = new Blob [data], {type: 'application/octet-binary'}
          writer.write blob
    else
      console.log "can't save outside of chrome app"

  saveComplete : ->
    @reset()

  addFrame : (skelData) ->
    if @position + skelData.length <= @skeletonDatas.length
      @skeletonDatas.set skelData, @position
      @position += skelData.length
      @length = @position + skelData.length
    @currDeltaTime = 0

  update : (dt) ->
    @currDeltaTime += dt