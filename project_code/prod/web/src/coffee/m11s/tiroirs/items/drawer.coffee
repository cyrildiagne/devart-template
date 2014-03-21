class mk.m11s.tiroirs.Drawer extends mk.m11s.SimplePartItem

  constructor: (@symbol, @part) ->
    super @symbol, @part
    maxW = @part.joints[0].radius*2
    @view.scale maxW / @view.bounds.width