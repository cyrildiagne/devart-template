class mk.m11s.birds.BackLight
  
  constructor : (@leftFoot, @rightFoot) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = -9999 -3
    @view.visible = false

    @path = new paper.Path()
    @path.fillColor = mk.Scene::settings.getHexColor 'lightBlue'
    @path.opacity = 0.2
    @path.segments = [
      [300, -window.viewport.height * 0.5]
      [0, 800]
      [0, 800]
    ]
    @view.addChild @path

    @thick = 150
    @amp = 0.01

    @x = 0
    @y = @getMinY()

    @gnd = new paper.Path.Circle [0, 0], @thick
    @gnd.fillColor = mk.Scene::settings.getHexColor 'lightBlue'
    @gnd.transformContent = false
    @gnd.scaling = new paper.Point 0.01,0.2

    @view.addChild @gnd

    @tween = null

  clean : ->
    if @tween then @tween.stop()
    @view.remove()

  show: ->
    v = @path
    thick = @thick
    @tween = new TWEEN.Tween(@)
    .to({amp:1}, 8000)
    .start window.currentTime
    @view.visible = true

  hide: (callback) ->
    v = @path
    thick = @thick
    @tween = new TWEEN.Tween(@)
    .to({amp:0}, 1000)
    .onComplete(=>
      v.visible = false
      callback() if callback
    )
    .start window.currentTime

  getMinY : ->
    minY = @leftFoot.y
    minY = @rightFoot.y if @rightFoot.y < minY
    return minY

  update : (dt) ->
    @x += ((@leftFoot.x + @rightFoot.x) * 0.5 - @x) * 0.0025 * dt
    @y += (@getMinY()-@y) * 0.0025 * dt
    @path.segments[1].point.x = @x - @thick * @amp
    @path.segments[2].point.x = @x + @thick * @amp
    @path.segments[1].point.y = @path.segments[2].point.y = @y
    # console.log @x + ' ' + @y
    @gnd.position.x = @x
    @gnd.position.y = @y
    @gnd.scaling = new paper.Point @amp, @amp*0.2
