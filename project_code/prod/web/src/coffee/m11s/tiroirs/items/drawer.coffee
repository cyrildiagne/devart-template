class mk.m11s.tiroirs.Drawer extends mk.helpers.SimplePartItem

  constructor: (@symbol, @part) ->
    super @symbol, @part, 'Drawer'+@part
    maxW = @part.joints[0].radius*2
    @view.scale maxW / @view.bounds.width