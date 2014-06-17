class mk.m11s.thorns.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/thorns/flower1.svg'
      'assets/items/thorns/flower2.svg'
      'assets/items/thorns/flower3.svg'
      'assets/items/thorns/head.svg'
      'assets/items/thorns/peak1.svg'
      'assets/items/thorns/peak2.svg'
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

  setupSounds : ->

    @track = 'assets/sounds/thorns/track/thorns_010.mp3'

    @musicEvents = [
    20.000 # guitar
    13.250 # rythmique
    34.150 # (instru)
    89.070 # piano
    # (piano grave)
    # (piano)
    # (piano grave)
    # (piano)
    # (piano grave) 
    130.150 # end
    ]