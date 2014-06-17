class mk.Scene 

  sfx      : null
  assets   : null
  settings : null

  constructor : (@onSceneReady, @onSceneFinished) ->
    @assets = new mk.Assets
    @sounds = new mk.sound.Sounds
    @music = new mk.sound.Music @onMusicEvent
    @music.endCallback = @endCallback
    @settings = null
    @perso = null
    @isLoading = false
    @delta = 0
    @numMesure = 0
    @isStarted = false
    @loops = []

  setMetamorphose : (type) ->
    if @isLoading then return
    @isLoading = true

    @settings = new (m11Class 'Settings')()
    Scene::settings = @settings

    dispatch 'loading:graphics'
    @assets.load type, @settings.assets, =>

      Scene::assets = @assets.symbols[type]

      dispatch 'loading:sound effects'
      @sounds.load type, @settings.sfx, =>

        loops = @loops
        Scene::sfx = @sounds.sfx[type]
        Scene::sfx.play = (s) ->
          sound = @[s].play()
          if Scene::settings.mute
            sound.volume( 0 )
          if s.indexOf 'loop' > -1
            loops.push sound
          return sound

        dispatch 'loading:music'
        @music.load @settings, (err) =>

          if err
            @music = null
            console.log err

          if @perso is null or @perso.type isnt type
            if @perso
              @perso.clean()
              @perso.view.remove()  
            @perso = new (m11Class 'Perso')()

          @perso.setMetamorphose @settings, @assets, @sounds
          # @start()

          # setTimeout @onMesure, 375 * 7
          # l.play() for k,l of @sounds.loops.tribal
          # for k,l of @sounds.loops.tribal
          #   if k != 'tactac'
          #     l.volume 0
          # @sounds.loops.tribal.deltafeu_b.volume 0

          @isLoading = false
          if @onSceneReady
            onSceneReady()

  endCallback : =>
    if @onSceneFinished
      @onSceneFinished()

  setDebug : (@debug) ->
    @perso.view.fullySelected = @debug

  setPersoPose : (skeleton) ->
    @perso.setPoseFromSkeleton skeleton

  update : (dt, currentTime) ->
    @music.update dt, currentTime
    @perso.update dt
    @delta += dt

  mute : ->
    @settings.mute = true
    @music.mute()
    s.volume(0) for s in @loops
    dispatch 'mute'

  unmute : ->
    @settings.mute = false    
    @music.unmute()
    s.volume(1) for s in @loops
    dispatch 'unmute'

  toggleMute : ->
    if @settings.mute
      @unmute()
    else @mute()

  stop : ->
    @isStarted = false
    if @music
      @music.stop()
    s.volume(0) for s in @loops

  start : ->
    @isStarted = true
    if @music and !@music.isFinished
      @music.play()
    s.volume(1) for s in @loops

  fadeOut : ->
    if @music
      @music.fadeOut()

  onMusicEvent : (eventId) =>
    @perso.onMusicEvent eventId

  # onMesure : =>
  #     @numMesure++
  #     pos = @sounds.loops.tribal.basse_a.pos() * 1000
  #     if(@numMesure%4==0)
  #       @rdmVolume()
  #     if @numMesure > 4
  #       violon = @sounds.oneshots.tribal.violon_c
  #       if Math.random()>0.9 and violon.pos() is 0
  #         violon.play()

  #     @delta = 0
  #     setTimeout @onMesure, (@numMesure+1)*375*7 - pos

  # rdmVolume : ->
  #   numSoundOn = 0
  #   for k,l of @sounds.loops.tribal
  #     if k is 'deltafeu_b' then continue
  #     v = Math.random()
  #     if v < 0.7
  #       v = 0
  #     else numSoundOn++
  #     l.volume v
  #   if numSoundOn is 0
  #     @rdmVolume()