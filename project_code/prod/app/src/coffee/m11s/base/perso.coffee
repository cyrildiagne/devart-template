class mk.m11s.base.Perso

  constructor : () ->
    @view = new paper.Layer()
    @type = 'base'
    @joints = []
    @parts  = []
    @morph  = null
    @items  = null
    @numItems = 0
    @sort = @paperSort

  setMetamorphose : (@settings, @assets, @sounds) ->
    @clean() if @items
    @setupJoints window.jointRatio
    @setupParts()
    @setupItems()
    @setupMorph()

  clean : () ->
    @joints.splice 0, @joints.length
    for part in @parts
      part.clean()
    @parts.splice 0, @parts.length
    if @items
      @items.clean()
      item.view.remove() for item in @items.items
      @items.items.splice 0, @items.items.length
    @view.removeChildren()

  setupMorph : () ->
    MorphClass = m11Class 'Morph'
    @morph = new MorphClass @joints, @settings.morph

  setupItems : () ->
    @items = new (m11Class 'BodyItems') @settings, @assets, @sounds, @parts, @joints, @view
    @numItems = @items.items.length
    for item in @items.items
      @view.addChild item.view

  setupJoints : (refWidth) ->
    JointClass = m11Class 'Joint'
    for i in [0...NiTE.NUM_JOINTS]
      jnt = new JointClass i, @settings.radius[i] * refWidth
      @joints.push jnt

  setupParts: () ->
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

  update : (delta) ->
    if @items
      for item in @items.items
        if item.view.parent isnt @view
          @view.addChild item.view
      @items.update delta
    # @sort()

  getJoints: (types) ->
    res = []
    for type in types
      res.push @joints[type]
    return res

  setPoseFromSkeleton: (skeleton) ->
    if !@joints then return

    for i in [0...skeleton.joints.length]
      @joints[i].x = skeleton.joints[i].view.position.x
      skeleton.joints[i].view.position.y += 10
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
    
    pelvis = @getPart('pelvis')
    torso = @getPart('torso')
    leftUpperLeg = @getPart('leftUpperLeg')
    rightUpperLeg = @getPart('rightUpperLeg')
    @getPart('head').updateZ torso.z + 2 # head always 'just' on top of body
    pelvis.updateZ torso.z + 1 # pelvis always 'just' on top of body
    leftUpperLeg.updateZ  pelvis.z - 1
    rightUpperLeg.updateZ  pelvis.z - 1
    @sort()

  paperSort : ->
    # console.time("paperSort")
    arr = @view.children.slice 0
    arr.sort (a, b) ->
      return if a.z > b.z then 1 else -1
    for i in [0...arr.length-1]
      if !arr[i+1].isAbove(arr[i])
        arr[i+1].insertAbove arr[i]
    # console.timeEnd("paperSort")


  # 10x faster than @paperSort but breaks up rendering if items are being removed
  fastSort : ->
    # console.time("fastSort")
    @view.children.sort (a, b) ->
      return if a.z > b.z then 1 else -1
    # console.timeEnd("fastSort")


  onMusicEvent: (eventId) ->
    @items.onMusicEvent eventId
