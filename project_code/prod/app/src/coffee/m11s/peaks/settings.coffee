class mk.m11s.peaks.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/peaks/flower1.svg'
      'assets/items/peaks/flower2.svg'
      'assets/items/peaks/flower3.svg'
      'assets/items/peaks/head.svg'
      'assets/items/peaks/peak1.svg'
      'assets/items/peaks/peak2.svg'
    ]

  setupColors : ->
    @colors =
      head          : @palette.red
      torso         : @palette.darkGray
      pelvis        : @palette.darkGray
      leftUpperArm  : @palette.red
      leftLowerArm  : @palette.red
      rightUpperArm : @palette.lightRed
      rightLowerArm : @palette.lightRed
      leftUpperLeg  : @palette.darkGray
      leftLowerLeg  : @palette.lightGreen
      rightUpperLeg : @palette.darkGray
      rightLowerLeg : @palette.lightGreen