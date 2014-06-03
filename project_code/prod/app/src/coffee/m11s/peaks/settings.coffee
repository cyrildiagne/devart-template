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

  setupSounds : ->

    @track = 'assets/sounds/thorns/track/thorns_010.mp3'

    @musicEvents = [
    # tiroirs apparaissent
      26.409 # rythmique - 
    # objets verticaux sortent
      67.216 # piano
    # objets sortent des tiroirs
      74.227 # piano + grave)
      84.005 # guitare
    # apparition des objets volants
      93.288 # guitare + grave)
      102.956 # guitare + aigue)
      103.166 # nappe
      142.320 # break
    # boutons + feuilles sortent des tiroirs
      170.464 # nappe + aigue
      179.979  # end 
    # tiroirs grandissent puis sortent
    ]