class mk.m11s.tribal.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tribal/head.svg'
    ]

  setupSounds: ->
    @loops = [
      'assets/sounds/tribal/loop/basse_a.mp3'
      'assets/sounds/tribal/loop/basse_b.mp3'
      'assets/sounds/tribal/loop/deltafeu_b.mp3'
      'assets/sounds/tribal/loop/synth_loop.mp3'
      'assets/sounds/tribal/loop/tactac.mp3'
    ]
    @oneshots = [
      'assets/sounds/tribal/oneshot/deltafeu_c.mp3'
      'assets/sounds/tribal/oneshot/violon_c.mp3'
    ]

  setupColors : ->
    super()
    @colors.leftLowerLeg = @palette.darkGray
    @colors.rightLowerLeg = @palette.darkGray