class mk.m11s.lockers.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/lockers/key1.svg'
      'assets/items/lockers/key2.svg'
      'assets/items/lockers/locker1.svg'
      'assets/items/lockers/locker2.svg'
      'assets/items/lockers/locker3.svg'
      'assets/items/lockers/pile1.svg'
      'assets/items/lockers/pile2.svg'
      'assets/items/lockers/pile3.svg'
    ]

   setupSounds : ->

    @track = 'assets/sounds/lockers/track/lockers_034.mp3'

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

    @sfx =
      openLock : 'OuvreSerrure_1'
      flyloop1 : 'Vole_GRAND_2'
      flyloop2 : 'Vole_MOYEN_2'
      flyloop3 : 'Vole_PETIT_2'