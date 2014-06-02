class mk.m11s.birds.Settings extends mk.m11s.base.Settings

  setupAssets : ->
    @assets = [
      'assets/items/birds/flower1.svg'
      'assets/items/birds/flower2.svg'
      'assets/items/birds/nest1.svg'
      'assets/items/birds/house1.svg'
      'assets/items/birds/house2.svg'
      'assets/items/birds/house3.svg'
      'assets/items/birds/house_side1.svg'
      'assets/items/birds/house_side2.svg'
      'assets/items/birds/house_side3.svg'
      'assets/items/birds/house1_night.svg'
      'assets/items/birds/house2_night.svg'
      'assets/items/birds/house3_night.svg'
      'assets/items/birds/house_side1_night.svg'
      'assets/items/birds/house_side2_night.svg'
      'assets/items/birds/house_side3_night.svg'
      'assets/items/birds/bird1.svg'
      'assets/items/birds/bird2.svg'
      'assets/items/birds/luciole.svg'
    ]

  setupSounds : ->

    @track = 'assets/sounds/birds/track/trees_008.mp3'

    @musicEvents = [
      #apparition maisons
      21.321  # nappe
      #apparition branches
      42.686  # rythmique
      #apparition fleurs / feuilles
      53.346  - 0.5# violon
      #apparition oiseaux
      60.300  # 2eme violon
      # oiseaux rentrent / sortent maisons
      96.010  # break
      # oiseaux rentent dans les maisons
      # lune apparait
      # changement de couleur progressif
      106.671 + 0.3 # reprise rythmique
      # apparition des lucioles
      117.342 # retour violon
      138.669 # 2eme violon
      159.995 # break
      176.046 # fadeout
    ]