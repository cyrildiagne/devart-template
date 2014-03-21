class mk.m11s.base.Perso

  constructor : () ->
    @view = new paper.Layer()

    @joints = null
    @parts  = null
    @morph  = null
    @items  = null

  setMetamorphose : (@settings, @assets) ->
    @setupJoints()
    @setupParts()
    @setupMorph()
    @setupItems()

  setupMorph : () ->
    MorphClass = m11Class 'Morph'
    @morph = new MorphClass @joints, @settings.morph

  setupItems : () ->
    @items = new (m11Class 'BodyItems') @assets, @parts, @joints
    for item in @items.items
      @view.addChild item.view

  setupJoints : () ->
    @joints = []
    JointClass = m11Class 'Joint'
    for i in [0...NiTE.NUM_JOINTS]
      jnt = new JointClass i, @settings.radius[i] * 1280
      @joints.push jnt

  setupParts: () ->
    @parts = []
    for name, parts of @settings.partsDefs
      jts = @getJoints(parts)
      color = @settings.colors[name]
      switch name
        when 'head'
          HeadClass = m11Class 'Head'
          part = new HeadClass name, jts, color, 0
        when 'torso'
          TorsoClass = m11Class 'Torso'
          part = new TorsoClass name, jts, color, 7, false
        when 'pelvis'
          PelvisClass = m11Class 'Pelvis'
          part = new PelvisClass name, jts, color, 6, false
        else
          PartClass = m11Class 'Part'
          part = new PartClass name, jts, color
      @view.addChild part.view
      @parts.push part

  resize : () ->
    # todo set circle radius

  update : () ->
    if @items
      @items.update()

  getJoints: (types) ->
    res = []
    for type in types
      res.push @joints[type]
    return res

  setPoseFromSkeleton: (skeleton) ->
    if !@joints then return

    for i in [0...skeleton.joints.length]
      @joints[i].x = skeleton.joints[i].view.position.x
      @joints[i].y = skeleton.joints[i].view.position.y
      @joints[i].z = skeleton.joints[i].z

    @morph.update()
    @updateParts()

  getPart: (name) ->
    for part in @parts
      if part.name == name then return part

  updateParts: ->
    for part in @parts
      part.update()
    @getPart('head').updateZ    @getPart('torso').z + 2 # head always 'just' on top of body
    @getPart('pelvis').updateZ  @getPart('torso').z + 1 # pelvis always 'just' on top of body
    @view.children.sort (a, b) ->
      return if a.z > b.z then 1 else -1