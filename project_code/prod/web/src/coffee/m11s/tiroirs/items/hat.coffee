class mk.m11s.tiroirs.Hat extends mk.m11s.SimpleJointItem

  constructor: (@symbol, @joint, @mirror=false) ->
    super @symbol, @joint
    @view.scale(-1,1) if @mirror