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
    @track = 'assets/sounds/birds/track/Trees_short_004.mp3'
    @musicEvents = [
      #apparition maisons
      # nappe
      #apparition branches
      10.430 # rythmique
      #apparition fleurs / feuilles
      21.270 - 0.5 # violon
      #apparition oiseaux
      32.090 # 2eme violon
      # oiseaux rentrent / sortent maisons
      42.430 # croisement violons ! NEW
      64.260 # break
      # oiseaux rentent dans les maisons
      # lune apparait
      # changement de couleur progressif
      74.430 + 0.3 # reprise rythmique
      # apparition des lucioles
      85.260 # retour violon
      106.440 # 2eme violon
      128.100 # break
      # fadeout  a disparu avec cut !
    ]
    @sfx =
      nightbird1 : 'OiseauSenvole_MOYEN_1-SansCri'
      nightbird2 : 'OiseauSenvole_GRAND_2-SansCri'
      house1     : 'MaisonBascule_3-PETITE'
      house2     : 'MaisonBascule_3-MOYENNE'
      house3     : 'MaisonBascule_3-GRANDE'
      branch1    : 'BrancheQuiPousse_PETITE_2'
      branch2    : 'BrancheQuiPousse_MOYENNE_1'
      bird1      : 'OiseauBranche_3-PETIT'
      bird2      : 'OiseauBranche_2-GRAND'