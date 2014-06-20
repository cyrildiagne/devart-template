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
      'assets/items/tiroirs/cups.svg'
      'assets/items/tiroirs/ruler.svg'
      'assets/items/tiroirs/windmill.svg'
      'assets/items/tiroirs/hand.svg'
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

    @track = 'assets/sounds/tiroirs/track/Drawers_short_002.mp3'

    @musicEvents = [
    # tiroirs apparaissent
      12.040 # rythmique - 
    # objets verticaux sortent
      50.210 # piano
    # objets sortent des tiroirs
      60.020 # piano + grave)
      69.300 - 0.5 # guitare
    # apparition des objets volants
      78.440 # guitare + grave)
      88.270 # guitare + aigue)
      88.380 # nappe
      108.010 # break
    # boutons + feuilles sortent des tiroirs
      117.290 # nappe + aigue
      127.080  # end 
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