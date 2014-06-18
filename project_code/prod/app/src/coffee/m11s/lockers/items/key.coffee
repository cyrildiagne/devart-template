class mk.m11s.lockers.Key extends mk.helpers.Flying
  
  constructor : (@id) ->
    rngk = 'key' + @id
    asset = ['key1', 'key2'].seedRandom rngk
    symbol = mk.Scene::assets[asset]
    @item = symbol.place()
    @item.pivot = new paper.Point 0, 0
    super @item, rngk,
      color1 : mk.Scene::settings.getHexColor 'cream'
      color2 : mk.Scene::settings.getHexColor 'lightRed'
      wingWidth : 350
      wingHeight : 0
      velocity : new paper.Point 3+rng(rngk)*2, 0
      wingSpeed : 0.7
      pos : new paper.Point -400, (rng(rngk)-0.5) * 800 - 50
    @view.scaling = rng(rngk)*0.2 + 0.8
    @view.pivot = new paper.Point @item.bounds.width*0.5,0
    @view.z = 9999

    i = rngi('key'+@id, 1,3)
    @sfx = mk.Scene::sfx.play 'flyloop' + i

  addMask : ->
    w = @item.bounds.width
    h = @item.bounds.height
    @mask = new paper.Path.Rectangle [0,0], [w,h]
    @mask.pivot = new paper.Point 0,0
    @mask.position = new paper.Point -w*0.5, -h*0.5
    @mask.fillColor = 'red'
    @mask.transformContent = false
    @view.insertChild 0, @mask
    @view.clipped = true

  turn : (callback) ->
    @addMask()
    v = @view
    m = @mask
    initMaskX = m.position.x
    tween = new TWEEN.Tween( { x : 0 } )
     .to( { x: 40 }, 150 )
     .easing( TWEEN.Easing.Quadratic.Out )
     .onUpdate( ->
        v.position.x = @x
        m.position.x = initMaskX - @x
     )
     .onComplete( ->
        mk.Scene::sfx.play 'openLock'
        tween = new TWEEN.Tween( { scale: v.scaling.y } )
         .to( { scale: v.scaling.y * 0.7 }, 250 )
         .onUpdate( ->
            v.scaling = new paper.Point v.scaling.x, @scale
         )
         .onComplete(->
            callback() if callback
         ).start window.currentTime
     ).start window.currentTime

  clean : ->
    @sfx.stop()
    @stop()
    @view.remove()