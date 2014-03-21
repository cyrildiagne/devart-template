class mk.m11s.base.BodyItems

  constructor : (@assets, @parts, @joints) ->
    @items = []
    @setupItems()

  setupItems : () ->
    #...
    
  update : () ->
    item.update() for item in @items

  getParts : (names) ->
    parts = @parts.filter (p) ->
      p.name in names
    return parts

  getJoints : (types) ->
    joints = @joints.filter (j) ->
      j.type in types
    return joints