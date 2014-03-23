class mk.m11s.base.BodyItems

  constructor : (@settings, @assets, @parts, @joints) ->
    @items = []
    @setupItems()

  setupItems : () ->
    #...
    
  clean : ->
    for item in @items
      if item.clean then item.clean()

  update : () ->
    item.update() for item in @items

  getPart : (name) ->
    return (@getParts [name])[0]

  getParts : (names) ->
    parts = @parts.filter (p) ->
      p.name in names
    return parts

  getPartsExcluding : (names) ->
    parts = @parts.filter (p) ->
      p.name not in names
    return parts

  getJoints : (types) ->
    joints = @joints.filter (j) ->
      j.type in types
    return joints

  getJointsExcluding : (types) ->
    joints = @joints.filter (j) ->
      j.type not in types
    return joints