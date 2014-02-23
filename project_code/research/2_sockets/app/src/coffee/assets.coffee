class Assets

  constructor : () ->
    @img_suffix = ''
    if window.devicePixelRatio > 1.0
      @img_suffix = '-hd'

  load : (callback) ->
    assetsToLoad = [ 'assets/plop_anim' + @img_suffix + '.json']
    loader = new PIXI.AssetLoader(assetsToLoad)
    loader.onComplete = callback
    loader.load()