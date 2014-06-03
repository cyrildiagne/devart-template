class mk.m11s.tribal.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/tribal/head.svg'
    ]

   setupSounds : ->

    @track = 'assets/sounds/tribal/track/tribal_025.mp3'

    @musicEvents = [
    # tiroirs apparaissent
      26.409 # rythmique - 
    # objets verticaux sortent
      67.216 # piano
    # objets sortent des tiroirs
      74.227 # piano + grave)
      84.005 # guitare
    # apparition des objets volants
      93.288 # guitare + grave)
      102.956 # guitare + aigue)
      103.166 # nappe
      142.320 # break
    # boutons + feuilles sortent des tiroirs
      170.464 # nappe + aigue
      179.979  # end 
    # tiroirs grandissent puis sortent
    ]

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