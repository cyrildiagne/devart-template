class mk.m11s.stripes.BodyItems extends mk.m11s.base.BodyItems

  setupItems: ->
    @physics = null
    @setupPhysics()
    @balls = null
    @addBalls()
    delayed 1000, =>
      # @balls.ballsToAdd.push null for i in [0...10]
      @balls.intervalBall()
    
  setupPhysics: ->
    @physics = new mk.helpers.Physics()
    @physics.addPersoPartRect @getPart('leftLowerArm')
    @physics.addPersoPartRect @getPart('rightLowerArm')
    @physics.addPersoPartRect @getPart('leftUpperArm')
    @physics.addPersoPartRect @getPart('rightUpperArm')

    
    # @physics.addPersoPartRect @getPart('rightUpperLeg')
    # @physics.addPersoPartRect @getPart('leftUpperLeg')
    # @physics.addPersoPartRect @getPart('rightLowerLeg')
    # @physics.addPersoPartRect @getPart('leftLowerLeg')

  update: (dt) ->
    @physics.update dt
    super dt

  addBalls: ->
    @balls = new mk.m11s.stripes.Balls @physics
    @items.push @balls