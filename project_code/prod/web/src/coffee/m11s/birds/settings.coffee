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
    ]

  setupSounds : ->

    @track = 'assets/sounds/birds/track/trees_008.mp3'

    @musicEvents = [
      21.321  # nappe
      42.686  # rythmique
      53.346  - 0.5# violon
      60.300  # 2eme violon
      96.010  # break
      106.671 # reprise rythmique
      117.342 # retour violon
      138.669 # 2eme violon
      159.995 # break
      183.304 # end
    ]