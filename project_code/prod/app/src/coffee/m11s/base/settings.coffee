class mk.m11s.base.Settings
  
  constructor: ->
    @sfx = {}
    @setupAssets()
    @setupSounds()
    @setupMorph()
    @setupRadius()
    @setupPalette()
    @setupColors()
    @setupPartsDefinitions()

  setupAssets: ->
    @assets = []

  setupSounds: ->

  setupMorph : ->
    @morph =
      shouldersToHead   : 0.6
      shouldersAppart   : 0.6
      elbowsToShoulders : 0.25
      torsoLow          : 0.3
      hipsCloser        : 0.25
      lowFeet           : 0.2

  setupRadius : ->
    @radius = [
      0.020, # HEAD
      0,     # NECK
      0.008, # LEFT_SHOULDER
      0.008, # RIGHT_SHOULDER
      0.003, # LEFT_ELBOW
      0.003, # RIGHT_ELBOW
      0.003, # LEFT_HAND
      0.003, # RIGHT_HAND
      0.020, # TORSO
      0.012, # LEFT_HIP
      0.012, # RIGHT_HIP
      0.008, # LEFT_KNEE
      0.008, # RIGHT_KNEE
      0.003, # LEFT_FOOT
      0.003, # RIGHT_FOOT
    ]

  setupPalette : ->
    @palette =
      skin        : 0xdec6c2
      cream       : 0xe4e6dd
      lightBlue   : 0x97c6c9
      blue        : 0x629498
      beige       : 0xcac8ad
      lightGreen  : 0xb5cec0
      green       : 0x629498
      darkGray    : 0x282022
      red         : 0xAC3A43
      lightRed    : 0xEA4E74
      whiteGreen  : 0xE4E6DD

  getHexColor : (name) ->
    return '#' + @palette[name].toString 16

  getPaperColor : (name) ->
    return new paper.Color(@getHexColor(name))

  setupColors : ->
    @colors =
      head          : @palette.skin
      torso         : @palette.cream
      pelvis        : @palette.lightBlue
      leftUpperArm  : @palette.beige
      leftLowerArm  : @palette.beige
      rightUpperArm : @palette.lightGreen
      rightLowerArm : @palette.lightGreen
      leftUpperLeg  : @palette.lightBlue
      leftLowerLeg  : @palette.blue
      rightUpperLeg : @palette.lightBlue
      rightLowerLeg : @palette.blue

  setupPartsDefinitions : ->
    @partsDefs =
      pelvis        : [ NiTE.TORSO,          NiTE.LEFT_HIP,       NiTE.RIGHT_HIP ]
      torso         : [ NiTE.TORSO,          NiTE.LEFT_SHOULDER,  NiTE.RIGHT_SHOULDER,  NiTE.HEAD ]
      leftUpperArm  : [ NiTE.LEFT_SHOULDER,  NiTE.LEFT_ELBOW ]
      leftLowerArm  : [ NiTE.LEFT_ELBOW,     NiTE.LEFT_HAND ]
      leftUpperLeg  : [ NiTE.LEFT_HIP,       NiTE.LEFT_KNEE ]
      leftLowerLeg  : [ NiTE.LEFT_KNEE,      NiTE.LEFT_FOOT ]
      rightUpperArm : [ NiTE.RIGHT_SHOULDER, NiTE.RIGHT_ELBOW ]
      rightLowerArm : [ NiTE.RIGHT_ELBOW,    NiTE.RIGHT_HAND ]
      rightUpperLeg : [ NiTE.RIGHT_HIP,      NiTE.RIGHT_KNEE ]
      rightLowerLeg : [ NiTE.RIGHT_KNEE,     NiTE.RIGHT_FOOT ]
      head          : [ NiTE.HEAD]