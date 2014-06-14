class mk.m11s.tiroirs.DrawerItem

  constructor: (@symbol, @drawer) ->
    @view = new paper.Group()

    @mask = new paper.Path.Rectangle [-250,0], [500,-window.viewport.height*0.5] 
    @view.addChild @mask

    @view.clipped = true
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.scaling = @drawer.scale * 2
    @zOffset = 400 - @drawer.follower.zOffset * 2
    @z = @zOffset

    @item = @symbol.place()
    @h = @item.bounds.height * 0.5
    @item.position.y = @h
    @view.addChild @item

    @sfxType = rngi('dri', 1,2)
    @rotation = 0

    @offset = new paper.Point 0,-10
    @updatePos()

    @tween = null

  updatePos : ->
    @view.position.x = @drawer.view.position.x + @offset.x
    @view.position.y = @drawer.view.position.y + @offset.y
    @view.z = @drawer.view.z + @zOffset

  show : ->
    @sfx = mk.Scene::sfx.play('itemAppear' + @sfxType)
    @sfx.volume 0.2 if @sfx
    new TWEEN.Tween(@offset).to({x:40*@drawer.scale,y:0}, 500).start window.currentTime
    it = @item
    if @tween then @tween.stop()
    @tween = new TWEEN.Tween({y:@h})
     .to({y:-@h}, 2000)
     .onUpdate(->
        it.position.y = @y
     ).start window.currentTime

  hide : ->
    new TWEEN.Tween(@offset).to({x:0,y:-10}, 400).start window.currentTime
    it = @item
    if @tween then @tween.stop()
    @tween = new TWEEN.Tween({y:it.position.y})
     .to({y:@h+1}, 400)
     .onUpdate(->
        it.position.y = @y
     ).start window.currentTime

  update: (dt) ->
    d = (@view.position.x - @drawer.view.position.x - @offset.x) * 3
    @view.rotation += (d - @view.rotation)*0.003*dt
    @view.rotation *= 0.97
    @updatePos()