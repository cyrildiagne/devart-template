class mk.m11s.bulbs.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/bulbs/bulb_socket.svg'
    ]

  setupColors : ->
    @colors =
      head          : @palette.green
      torso         : @palette.lightBlue
      pelvis        : @palette.lightBlue
      leftUpperArm  : @palette.blue
      leftLowerArm  : @palette.green
      rightUpperArm : @palette.green
      rightLowerArm : @palette.green
      leftUpperLeg  : @palette.green
      leftLowerLeg  : @palette.green
      rightUpperLeg : @palette.green
      rightLowerLeg : @palette.green

  setupSounds : ->

    @track = 'assets/sounds/bulbs/track/bulbs_004.mp3'

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