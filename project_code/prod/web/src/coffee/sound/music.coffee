class mk.sound.Music

  constructor : (@onMusicEvent) ->
    @track = null
    @isPlaying = false
    @animTime = 0
    @nextEventTime = -1
    @currEvent = 0
    @soundId = null
    @bSettingPos = false

  load : (@settings, callback) ->
    path = @settings.track
    @track = new Howl
      urls : [ path ]
      onload : =>
        if callback
          callback()
      onloaderror : ->
        console.log "error loading #{url}"
      onplay : @onPlay

  play : ->
    if !@isPlaying
      @track.play()
      @bSettingPos = true
      @track.pos @animTime
      @bSettingPos = false
      @isPlaying = true
    else
      console.log 'already playing'
      
      # @track.mute()

  stop : ->
    @track.pause()
    @isPlaying = false
    console.log '> Music paused'

  update : (dt, currentTime) ->
    @animTime = currentTime / 1000
    if @animTime > @nextEventTime
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
        console.log 'Setting next event at ' + @nextEventTime + 's'
        break

  onPlay : () =>
    if !@bSettingPos then return
    if @track.pos() > @nextEventTime
      @setNextEvent()
    log = '> Music playing :' + '\n'
    log += 'playhead is at : ' + @track.pos().toFixed(3) + 's (anim is at ' + @animTime + 's)\n'
    log += 'next event is at : ' + @nextEventTime + 's'
    console.log log