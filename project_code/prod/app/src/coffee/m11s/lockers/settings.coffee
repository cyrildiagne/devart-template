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
      'assets/items/lockers/door.svg'
    ]

   setupSounds : ->

    @track = 'assets/sounds/lockers/track/Lockers_short_002_RecutBea.mp3'

    @musicEvents = [
      # 4.140 # piano
      # 21.000 # piano aigu
      # 36.160 # violon
      # 52.130 # 2e violon
      # 84.120 # rythmique
      # 100.000 # piano
      # 116.130 # (rythmique) 
      # 140.130 # final (non flagrant)
      # 146 # end

      # version short - 16 secondes (cut vers 2:12 minutes)
      4.140 # piano
      21.000 # piano aigu
      36.160 # violon
      52.130 # 2e violon
      84.120 # rythmique
      100.000 # piano
      116.130 # (rythmique) 
      124.130 # final (non flagrant)
      130 # end
    ]

    @sfx =
      openLock : 'OuvreSerrure_1'
      flyloop1 : 'CleVole_5-GRAND'
      flyloop2 : 'CleVole_5-MOYEN'
      flyloop3 : 'CleVole_5-PETIT'
      sandfly1 : 'SableSenvole_PETIT'
      sandfly2 : 'SableSenvole_MOYEN'
      sandfly3 : 'SableSenvole_GRAND'

  # setupColors : ->
  #   super()
  #   @colors['leftUpperLeg'] = @palette.blue
  #   @colors['rightUpperLeg'] = @palette.blue
  #   @colors['pelvis'] = @palette.blue