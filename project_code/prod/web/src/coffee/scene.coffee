class mk.Scene 

  constructor : (@onSceneReady) ->
    @assets = new mk.Assets
    @sounds = new mk.Sounds
    @settings = null
    @perso = null
    @isLoading = false

    @delta = 0
    @numMesure = 0

  setMetamorphose : (type) ->
    if @isLoading then return
    @isLoading = true

    @settings = new (m11Class 'Settings')()

    @assets.load type, @settings.assets, =>
      # @sounds.load type, @settings.loops, @settings.oneshots, =>

        if @perso is null or @perso.type isnt type
          if @perso
            @perso.clean()
            @perso.view.remove()  
          @perso = new (m11Class 'Perso')()

        @perso.setMetamorphose @settings, @assets, @sounds
        
        # setTimeout @onMesure, 375 * 7
        # l.play() for k,l of @sounds.loops.tribal
        # for k,l of @sounds.loops.tribal
        #   if k != 'tactac'
        #     l.volume 0
        # @sounds.loops.tribal.deltafeu_b.volume 0

        @isLoading = false
        if @onSceneReady
          onSceneReady()

  setDebug : (@debug) ->
    @perso.view.fullySelected = @debug

  setPersoPose : (skeleton) ->
    @perso.setPoseFromSkeleton skeleton

  update : (dt) ->
    @perso.update dt
    @delta += dt

  onMesure : =>
      # @numMesure++
      # pos = @sounds.loops.tribal.basse_a.pos() * 1000
      # if(@numMesure%4==0)
      #   @rdmVolume()
      # if @numMesure > 4
      #   violon = @sounds.oneshots.tribal.violon_c
      #   if Math.random()>0.9 and violon.pos() is 0
      #     violon.play()

      # @delta = 0
      # setTimeout @onMesure, (@numMesure+1)*375*7 - pos

  rdmVolume : ->
    numSoundOn = 0
    for k,l of @sounds.loops.tribal
      if k is 'deltafeu_b' then continue
      v = Math.random()
      if v < 0.7
        v = 0
      else numSoundOn++
      l.volume v
    if numSoundOn is 0
      @rdmVolume()