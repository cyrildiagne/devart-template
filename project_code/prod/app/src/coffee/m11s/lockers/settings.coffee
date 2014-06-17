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

    @track = 'assets/sounds/lockers/track/Lockers_short_001.mp3'

    @musicEvents = [
      04.140 # piano
  21.000 # piano aigu
  36.160 # violon
  52.130 # 2e violon
  84.120 # rythmique
  100.000 # piano
  116.130 # (rythmique) 
  140.130 # end (non flagrant)
    ]

    @sfx =
      openLock : 'OuvreSerrure_1'
      flyloop1 : 'Vole_GRAND_2'
      flyloop2 : 'Vole_MOYEN_2'
      flyloop3 : 'Vole_PETIT_2'