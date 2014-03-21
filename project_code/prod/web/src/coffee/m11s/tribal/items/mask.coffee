class mk.m11s.tribal.Mask extends mk.m11s.SimpleJointItem

  constructor: (@symbol, @joint) ->
    super @symbol, @joint
    @view.scale 1.2

  update: () ->
    @follower.update()
    @view.position.y -= @view.bounds.height*0.35