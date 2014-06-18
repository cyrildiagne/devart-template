class mk.m11s.stripes.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @physics = null
    @setupPhysics()
    @fallings = null
    @umbrella = null
    delayed 1000, =>
      @addFalling()
      # @fallings.setMode 'all'
  
  onMusicEvent : (evId) ->
    ph = @physics
    g = ph.getGravity()
    switch evId
      when 2
        @fallings.setMode 'bottom'
      when 3
        @fallings.setMode 'left'
      when 4
        @fallings.setMode 'top'
        @addUmbrella()
      when 12
        @fallings.setMode 'bottom'
        delayed 13500, =>
          @umbrella.setStatic false
          @fallings.lockPop = true
      when 13
        @fallings.lockPop = false
        @fallings.shapeMode = 'rect'
        delayed 13500, =>
          @fallings.lockPop = true
      when 14
        @fallings.clear()
        @fallings.lockPop = false
        @fallings.shapeMode = 'circle'
        @fallings.setMode 'all'

  setupPhysics: ->
    @physics = new mk.helpers.Physics()
    @physics.addPersoPartRect @getPart('leftLowerArm')
    @physics.addPersoPartRect @getPart('rightLowerArm')
    @physics.addPersoPartRect @getPart('leftUpperArm')
    @physics.addPersoPartRect @getPart('rightUpperArm')

    @physics.addPersoJoint @joints[NiTE.HEAD]
    
    @physics.addPersoPartRect @getPart('rightUpperLeg')
    @physics.addPersoPartRect @getPart('leftUpperLeg')
    @physics.addPersoPartRect @getPart('rightLowerLeg')
    @physics.addPersoPartRect @getPart('leftLowerLeg')

  update: (dt) ->
    @physics.update dt
    super dt

  addFalling: ->
    @fallings = new mk.m11s.stripes.FallingItems @physics
    @items.push @fallings
    # @stage.addChild @fallings.viewVisible
    delayed 5400, =>
      @fallings.intervalItem()

  addUmbrella: ->
    @umbrella = new mk.m11s.stripes.Umbrella @physics, @getPart('rightLowerArm')
    @items.push @umbrella