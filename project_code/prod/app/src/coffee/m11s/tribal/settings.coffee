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
       # rythmique a disparu avec cut !
      21.0 # basses + sythe
      32.000 # synthe aigu
      # nappe a disparu avec cut !
      63.070 # instru
      90 # ?
      124.390 # (break)
      126.230 # end
    ]

    @sfx =
      fireloop : 'Feu_boucle_2'

  # setupSounds: ->
  #   @loops = [
  #     'assets/sounds/tribal/loop/basse_a.mp3'
  #     'assets/sounds/tribal/loop/basse_b.mp3'
  #     'assets/sounds/tribal/loop/deltafeu_b.mp3'
  #     'assets/sounds/tribal/loop/synth_loop.mp3'
  #     'assets/sounds/tribal/loop/tactac.mp3'
  #   ]
  #   @oneshots = [
  #     'assets/sounds/tribal/oneshot/deltafeu_c.mp3'
  #     'assets/sounds/tribal/oneshot/violon_c.mp3'
  #   ]

  setupColors : ->
    super()
    @colors.leftLowerLeg = @palette.darkGray
    @colors.rightLowerLeg = @palette.darkGray