class mk.m11s.tribal.Mask extends mk.helpers.SimpleJointItem

  constructor: (@symbol, @joint) ->
    super @symbol, @joint
    @view.scale 0.8
    @isHandOver = false
    @initY = 0

  update: () ->
    @follower.update()
    @view.position.y -= @view.bounds.height*0.35
    @view.z = @joint.z + 200

    p = @view.globalToLocal window.mouse
    
    if @isPointOverMask p

      w = @view.bounds.size.width
      r = (Math.abs(p.x)-w*0.5) * 0.4 * (if p.x>0 then -1 else 1)
      @view.rotation += (r-@view.rotation) * 0.1

      if !@isHandOver
        @isHandOver = true
        @initY = p.y
      d = (p.y-@initY)
      if d < 0
        @view.position.y += d
    else
      @view.rotation += (0-@view.rotation)*0.1
      if @isHandOver
        @isHandOver = false
      

  isPointOverMask: (p) ->
    v = @view.bounds.size
    if p.x > -v.width*0.5 && p.x < v.width*0.5 && p.y > -v.height*0.5 && p.y < v.height*0.5
      return true
    return false
