class mk.Scene 

  constructor : (@onSceneReady) ->
    @assets = new mk.Assets
    @settings = null
    @perso = null
    @isLoading = false

  setMetamorphose : (type) ->
    if @isLoading then return
    @isLoading = true

    @settings = new (m11Class 'Settings')()

    @assets.load type, @settings.assets, =>
      
      if @perso is null or @perso.type isnt type
        if @perso
          @perso.clean()
          @perso.view.remove()  
        @perso = new (m11Class 'Perso')()

      @perso.setMetamorphose @settings, @assets
      
      @isLoading = false
      if @onSceneReady
        onSceneReady()

  setDebug : (@debug) ->
    @perso.view.fullySelected = @debug

  setPersoPose : (skeleton) ->
    @perso.setPoseFromSkeleton skeleton

  update : () ->
    @perso.update()

  resize : (viewport) ->
    if @perso
      @perso.resize viewport