class mk.m11s.tribal.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tribal/head.svg'
      'assets/items/tribal/shadow.svg'
    ]

   setupSounds : ->

    @track = 'assets/sounds/tribal/track/Tribal_short_004.mp3'

    @musicEvents = [
      5.235 # rythmique
      15.754 # basses + sythe
      25.380 # synthe aigu
      42.015 # nappe
      83.942 # instru
      105.759 # violon
      147.033 # end
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