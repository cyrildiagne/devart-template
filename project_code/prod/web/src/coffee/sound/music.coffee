class mk.sound.Music

  constructor : (@onMusicEvent) ->
    @track = null
    @isPlaying = false
    @animTime = 0
    @nextEventTime = -1
    @currEvent = 0
    @soundId = null
    @bSettingPos = false
    @endCallback = null
    @isFinished = false

  load : (@settings, loadedCallback) ->
    path = @settings.track
    @track = new Howl
      urls : [ path ]
      onload : =>
        if loadedCallback
          loadedCallback()
      onloaderror : ->
        console.log "> Music error loading #{url}"
      onend : =>
        @stop()
        console.log '> Music finished'
        if @endCallback
          @endCallback()
      onplay : @onPlay

  play : ->
    if !@isPlaying
      @track.play()
      @bSettingPos = true
      @track.pos @animTime
      # @track.pos 106.671 + 0.3
      @bSettingPos = false
      @isPlaying = true
    else
      console.log '> Music already playing'
      
      # @track.mute()

  stop : ->
    @track.pause()
    @isPlaying = false
    console.log '> Music paused'

  update : (dt, currentTime) ->
    if @isFinished
      return
    @animTime = currentTime / 1000
    if @animTime > @nextEventTime
      console.log '> Music Event ' + @currEvent
      @onMusicEvent @currEvent if @onMusicEvent
      @setNextEvent()

  mute : ->
    @track.mute()

  unmute : ->
    @track.unmute()

  setNextEvent : ->
    pos = @animTime
    evs = @settings.musicEvents
    for i in [0...evs.length]
      time = evs[i]
      if time > pos
        @currEvent = i
        @nextEventTime = time
        console.log '> Music setting next event at ' + @nextEventTime + 's'
        break
    if @nextEventTime < pos
      @isFinished = true

  onPlay : () =>
    if !@bSettingPos then return
    if @track.pos() > @nextEventTime
      @setNextEvent()
    log = '> Music playing :' + '\n'
    log += 'playhead is at : ' + @track.pos().toFixed(3) + 's (anim is at ' + @animTime + 's)\n'
    log += 'next event is at : ' + @nextEventTime + 's'
    console.log log