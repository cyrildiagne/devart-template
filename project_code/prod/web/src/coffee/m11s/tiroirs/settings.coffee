class mk.m11s.tiroirs.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tiroirs/drawer1.svg'
      'assets/items/tiroirs/drawer2.svg'
      'assets/items/tiroirs/hat.svg'
      'assets/items/tiroirs/necktie1.svg'
    ]
    

  setupColors : ->
    @colors =
      head          : @palette.skin
      torso         : @palette.red
      pelvis        : @palette.darkGray
      leftUpperArm  : @palette.beige
      leftLowerArm  : @palette.beige
      rightUpperArm : @palette.lightGreen
      rightLowerArm : @palette.lightGreen
      leftUpperLeg  : @palette.darkGray
      leftLowerLeg  : @palette.darkGray
      rightUpperLeg : @palette.darkGray
      rightLowerLeg : @palette.darkGray