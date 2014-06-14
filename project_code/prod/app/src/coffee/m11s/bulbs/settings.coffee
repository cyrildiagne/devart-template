class mk.m11s.bulbs.Settings extends mk.m11s.base.Settings
  
  setupAssets : ->
    @assets = [
      'assets/items/bulbs/bulb_socket.svg'
    ]

  setupColors : ->
    @colors =
      head          : @palette.green
      torso         : @palette.lightBlue
      pelvis        : @palette.lightBlue
      leftUpperArm  : @palette.blue
      leftLowerArm  : @palette.green
      rightUpperArm : @palette.green
      rightLowerArm : @palette.green
      leftUpperLeg  : @palette.green
      leftLowerLeg  : @palette.green
      rightUpperLeg : @palette.green
      rightLowerLeg : @palette.green

  setupSounds : ->

    @track = 'assets/sounds/bulbs/track/bulbs_004.mp3'

    @musicEvents = [
      36.006 # rythmique
      62.755 # xylophone
      84.502 # violon grave
      90.005 # (violon aigu)
      108.005 # violon grave
      114.005 # (violon aigu)
      120.506 # (violon grave)
      132.006 # end
    ]

    @sfx =
      ropeFalls    : 'Ampoule_3-2_cordeTombe'
      ropeReleased : 'Ampoule_OFF-1_cordeRelachee'
      ropeGrabbed  : 'Ampoule_ON-1'
      laserOn      : 'Ampoule_Scintille-1_laserGrandit'
      laserOff     : 'Ampoule_Scintille-2_laserDiminue'
      bulbShow1    : 'Ampoule_6-2'
      bulbShow2    : 'Ampoule_6-4'
      bulbShow3    : 'Ampoule_6-6'
      liftOut      : 'Ampoule_2-2_ascenseurArrivee'
      liftIn       : 'Ampoule_2-1_ascenseurDepart'