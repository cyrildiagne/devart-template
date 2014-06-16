class mk.m11s.tiroirs.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tiroirs/hat.svg'
      'assets/items/tiroirs/necktie1.svg'
      'assets/items/tiroirs/button1.svg'
      'assets/items/tiroirs/button2.svg'
      'assets/items/tiroirs/button3.svg'
      'assets/items/tiroirs/cane.svg'
      'assets/items/tiroirs/ladder.svg'
      'assets/items/tiroirs/belt.svg'
      'assets/items/tiroirs/umbrella.svg'
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


  setupSounds : ->

    @track = 'assets/sounds/tiroirs/track/tiroirs_006.mp3'

    @musicEvents = [
    # tiroirs apparaissent
      26.409 # rythmique - 
    # objets verticaux sortent
      67.216 # piano
    # objets sortent des tiroirs
      74.227 # piano + grave)
      84.005 - 0.5 - 8# guitare
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

    @sfx =
      drawerClose1 : 'Tirroir_Ferme_MOYEN_3'
      drawerClose2 : 'Tirroir_Ferme_GRAND_3'
      drawerOpen1  : 'Tirroir_Ouvert_GRAND_3'
      drawerOpen2  : 'Tirroir_Ouvert_MOYEN_3'
      itemAppear1  : 'ObjetquiSort_3'
      itemAppear2  : 'ObjetquiSort_3-2'
      itemFly      : 'OiseauSenvole_GRAND_1-SansCri'