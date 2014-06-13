class mk.m11s.stripes.Perso extends mk.m11s.base.Perso

  constructor : () ->
    @mask    = new paper.Group()
    @content = new paper.Group()
    @view    = new paper.Layer()
    @type = 'stripes'
    @joints = []
    @parts  = []
    @morph  = null
    @items  = null
    @stripes = null
    @count = 0
    @sort = -> console.log 'sort'

  clean : () ->
    if @stripes
      @stripes.clean()
      @stripes.view.remove()
    @content.removeChildren()
    @mask.removeChildren()
    @view.removeChildren()
    super()

  setupItems : () ->
    @items = new (m11Class 'BodyItems') @settings, @assets, @sounds, @parts, @joints
    @numItems = @items.items.length
    for item in @items.items
      @mask.addChild item.view

  setMetamorphose : (@settings, @assets) ->
    super @settings, @assets

    @view.addChild @mask
    @view.addChild @content
    @view.clipped = true
    @setupMaskContent()

  setupMaskContent : () ->

    @stripes = new mk.m11s.stripes.Stripes @settings, @joints[NiTE.TORSO], 10
    @content.addChild @stripes.view

    @circle = new paper.Path.Circle
      center: [0, 0],
      radius: 0,
    @mask.addChild(@circle)

  update : (delta) ->
    if @items
      for item in @items.items
        if item.view.parent isnt @mask
          @mask.addChild item.view
      @items.update delta

  resize : () ->
    # @view.position.x = 

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
      @mask.addChild part.view
      @parts.push part
    return

  updateParts: ->
    for part in @parts
      part.update()

    @stripes.update()
    @circle.position.x = Math.sin(++@count / 30) * 300 + 100