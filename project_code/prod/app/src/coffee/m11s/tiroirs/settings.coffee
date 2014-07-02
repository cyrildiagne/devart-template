class mk.m11s.tiroirs.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tiroirs/hat.svg'
      'assets/items/tiroirs/necktie1.svg'
      'assets/items/tiroirs/necktie2.svg'
      'assets/items/tiroirs/necktie3.svg'
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

    @track = 'assets/sounds/tiroirs/track/Drawers_short_002_RecutBea.mp3'

    @musicEvents = [
    # # tiroirs apparaissent
    #   12.040 # rythmique - 
    # # objets vertic<aux sortent
    #   50.210 # piano
    # # objets sortent des tiroirs
    #   60.020 # piano + grave)
    #   69.300 - 0.5 # guitare
    # # apparition des objets volants
    #   78.440 # guitare + grave)
    #   88.270 # guitare + aigue)
    #   88.380 # nappe
    #   108.010 # break
    # # boutons + feuilles sortent des tiroirs
    #   117.290 # nappe + aigue
    #   127.080  # final
    # # tiroirs grandissent puis sortent
    #   135 #end

    # version short - 19.09 secondes (cut vers 1:48 minutes)
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
      98.200 # nappe + aigue
      107.990  # final
    # tiroirs grandissent puis sortent
      115.91 #end 
    ]

    @sfx =
      drawerClose1 : 'Tirroir_Ferme_GRAND_3'
      drawerClose2 : 'Tirroir_Ferme_MOYEN_3'
      drawerClose3 : 'Tirroir_Ferme_PETIT_3'
      drawerOpen1  : 'Tirroir_Ouvert_GRAND_3'
      drawerOpen2  : 'Tirroir_Ouvert_MOYEN_3'
      drawerOpen3  : 'Tirroir_Ouvert_PETIT_3'
      itemAppear1  : 'ObjetquiSort_3'
      itemAppear2  : 'ObjetquiSort_3-2'
      itemAppear3  : 'ObjetquiSort_3-3'
      itemFly      : 'OiseauSenvole_GRAND_1-SansCri'
      itemFlyloop  : 'Ailes_Boucle_PETIT'