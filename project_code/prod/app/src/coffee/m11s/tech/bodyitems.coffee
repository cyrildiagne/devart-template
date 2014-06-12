class mk.m11s.tech.BodyItems extends mk.m11s.base.BodyItems

  setupItems : ->
    @hideBody()
    @addLines()

  hideBody : ->
    for p in @parts
      p.view.visible = false 

  addLines : ->
    parts = @getParts ['leftUpperArm', 'leftLowerArm','rightUpperArm','rightLowerArm']
    @lines = new mk.m11s.tech.Lines parts, @getPart('head'), @getPart('pelvis')
    @items.push @lines