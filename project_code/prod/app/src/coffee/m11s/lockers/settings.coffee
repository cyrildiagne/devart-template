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
      84
    ]

    @sfx =
      openLock : 'OuvreSerrure_1'
      flyloop1 : 'Vole_GRAND_2'
      flyloop2 : 'Vole_MOYEN_2'
      flyloop3 : 'Vole_PETIT_2'