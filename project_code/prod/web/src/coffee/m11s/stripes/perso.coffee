class mk.m11s.stripes.Perso extends mk.m11s.base.Perso

  constructor : () ->
    @mask    = new paper.Group()
    @content = new paper.Group()
    @view    = new paper.Layer(@mask, @content)
    # @view.clipped = true
    @type = 'stripes'
    @joints = []
    @parts  = []
    @morph  = null
    @items  = null
    @count = 0

  setMetamorphose : (@settings, @assets) ->
    super @settings, @assets
    @setupMaskContent()

  setupMaskContent : () ->

    rect = new paper.Path.Rectangle(0, 0, 200, 200)
    rect.fillColor = 'blue'
    @content.addChild(rect)

    @circle = new paper.Path.Circle
      center: [200, 200],
      radius: 100,
    @circle.fillColor = 'red'
    @mask.addChild(@circle)

  update : () ->
    return

  setupItems : () ->
    return

  setupParts: () ->
    return

  updateParts: ->
    return