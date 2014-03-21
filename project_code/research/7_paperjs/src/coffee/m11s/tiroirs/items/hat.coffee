class mk.m11s.tiroirs.Hat

  constructor: (@symbol, @joint, @mirror=false) ->
    @view = @symbol.place()
    @view.z = 0
    @view.scale(-1,1) if @mirror
    @follower = new mk.m11s.JointFollower @view, @joint

  update: () ->
    @follower.update()