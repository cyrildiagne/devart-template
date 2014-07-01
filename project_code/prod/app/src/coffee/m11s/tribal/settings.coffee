class mk.m11s.tribal.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tribal/head.svg'
      'assets/items/tribal/shadow.svg'
      'assets/items/tribal/circle_1.svg'
      'assets/items/tribal/circle_2.svg'
      'assets/items/tribal/circle_3.svg'
    ]

   setupSounds : ->

    @track = 'assets/sounds/tribal/track/Tribal_short_004.mp3'

    @musicEvents = [
###      # rythmique a disparu avec cut !  
      21.0 # basses + sythe
      32.000 # synthe aigu
      # nappe a disparu avec cut !
      63.070 # instru
      90 # ?
      124.390 # (break)
      126.230 # final
      139.705 # end###

      # version short - 21 secondes (cut vers 42 secondes)
      # rythmique a disparu avec cut !  
      21.0 # basses + sythe
      32.000 # synthe aigu
      # nappe a disparu avec cut !
      42.070 # instru
      69 # ?
      103.390 # (break)
      105.230 # final
      118.705 # end
    ]

    @sfx =
      fireloop    : 'Feu_boucle_4'
      windloop    : 'VentBoucle_Neutre_2'
      scenechange : 'Flute_1'
      featherout  : 'Plumes_5'
      maskon      : 'Plumes_ChimesSolo_4'

  setupColors : ->
    super()
    @colors.leftLowerLeg = @palette.darkGray
    @colors.rightLowerLeg = @palette.darkGray