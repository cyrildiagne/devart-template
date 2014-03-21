class mk.Scene 

  constructor : (m11) ->
    @assets = new mk.Assets
    @settings = null
    @perso = null
    @setMetamorphose m11

  setMetamorphose : (type) ->
    @settings = new (m11Class 'Settings')()
    @perso = @perso || new (m11Class 'Perso')()

    @assets.load type, @settings.assets, =>
      @perso.setMetamorphose @settings, @assets
      if @onSceneLoaded
        onSceneLoaded()

  setDebug : (@debug) ->
    @perso.view.selected = @debug

  setPersoPose : (skeleton) ->
    @perso.setPoseFromSkeleton skeleton

  update : () ->
    @perso.update()

  resize : (viewport) ->
    #...