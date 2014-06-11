class mk.m11s.books.Wave

  constructor : (@onAnimationComplete) ->
    @view = new paper.Group()
    @view.pivot = new paper.Point 0,0
    @view.transformContent = false

    @speed = 0.3

    @wave = mk.Scene::assets[ ['wave1','wave2'].random() ].place()
    @wave.speed = rng('wave') + 0.2
    @wave.speed *= @speed 

    @view.addChild @wave

    w = @view.bounds.width
    h = @view.bounds.height
    @mask = new paper.Path.Rectangle [-w,-h], [w*2, h]
    @mask.fillColor = 'red'
    @view.insertChild 0,@mask

    @view.clipped = true

    @view.position.x = (rng('wave')-0.5) * 300 - window.viewport.width*0.8
    @view.position.y = 200 + (rng('wave')-0.5) * 400
    @view.z = -2000 + @view.position.y
    @view.scale 0.5+rng('wave')*4

    waves = @waves
    w = @wave
    w.position.y = h*0.6
    w.rotation = -40
    w.scale(0.2)
    v = @view
    tween = new TWEEN.Tween({dt:0, scale:0.2})
    .to({dt:1, scale:1}, 3000 + rng('wave')*1000)
    .delay(rng('wave')*1000)
    .onUpdate(->
      w.position.y = h*0.6 + (0.5-Math.cos(@dt*2*Math.PI)*0.5) * -100
      w.rotation += 1.5
      w.scaling = @scale
      v.position.x += w.speed * 45
      # v.rotate 1
    )
    .onComplete(@onAnimationComplete)
    .start window.currentTime

  update : (dt) ->
    # @view.rotate 1