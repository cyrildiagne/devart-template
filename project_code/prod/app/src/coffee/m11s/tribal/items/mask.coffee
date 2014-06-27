class mk.m11s.tribal.Mask extends mk.helpers.SimpleJointItem

  constructor: (@symbol, @hand, @head) ->
    super @symbol, @hand
    @isOn = false

  update: () ->
    @follower.update()
    @view.position.y -= @view.bounds.height*0.35
    if !@isOn && @isMaskOverHead()
      @follower.joint = @head
      @follower.zOffset = 200
      @isOn = true
      @maskOnCallback() if @maskOnCallback
    
  isMaskOverHead: ->
    m = @view.position
    d = (m.x-@head.x) * (m.x-@head.x) + (m.y-@head.y) * (m.y-@head.y)
    return d < 60 * 60
