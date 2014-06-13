class mk.m11s.birds.Settings extends mk.m11s.base.Settings

  setupAssets : ->
    @assets = [
      'flower1.svg'
      'flower2.svg'
      'nest1.svg'
      'house1.svg'
      'house2.svg'
      'house3.svg'
      'house_side1.svg'
      'house_side2.svg'
      'house_side3.svg'
      'house1_night.svg'
      'house2_night.svg'
      'house3_night.svg'
      'house_side1_night.svg'
      'house_side2_night.svg'
      'house_side3_night.svg'
      'bird1.svg'
      'bird2.svg'
      'luciole.svg'
      'wildbird.svg'
    ]
    for i in [0...@assets.length]
      @assets[i] = 'assets/items/birds/' + @assets[i]

  setupSounds : ->
    @track = 'assets/sounds/birds/track/trees_008.mp3'
    @musicEvents = [
      #apparition maisons
      5
      #21.321  - 40# nappe
      #apparition branches
      42.686  - 33# rythmique
      #apparition fleurs / feuilles
      53.346  - 33 - 0.5# violon
      #apparition oiseaux
      60.300  - 33 # 2eme violon
      # oiseaux rentrent / sortent maisons
      96.010  - 33# break
      # oiseaux rentent dans les maisons
      # lune apparait
      # changement de couleur progressif
      106.671 - 33 + 0.3 # reprise rythmique
      # apparition des lucioles
      117.342 - 33# retour violon
      138.669 - 33# 2eme violon
      159.995 - 33# break
      176.046 - 33# fadeout
    ]
    @sfx = [
      'assets/sounds/birds/sfx/BrancheQuiPousse_1.mp3'
      'assets/sounds/birds/sfx/Maison_1.mp3'
      'assets/sounds/birds/sfx/OiseauBranche_1.mp3'
      'assets/sounds/birds/sfx/OiseauBranche_2.mp3'
    ]
    @loops = []