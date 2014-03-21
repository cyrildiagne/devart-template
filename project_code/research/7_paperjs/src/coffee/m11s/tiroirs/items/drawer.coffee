class mk.m11s.tiroirs.Drawer

  constructor: (@symbol, @part) ->
    @view = @symbol.place()
    @view.z = 0
    maxW = @part.joints[0].radius*2
    @view.scale maxW / @view.bounds.width
    @follower = new mk.m11s.PartFillFollower @view, @part, @getRandomWeights()

  getRandomWeights: ->
    weights = []
    sum = 0
    for j,i in @part.joints
      if i < 3
        w = Math.random()
        weights.push w
        sum += w
    weights[i] /= sum for w,i in weights
    return weights

  update: () ->
    @follower.update()