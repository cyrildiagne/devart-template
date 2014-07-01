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

    @track = 'assets/sounds/bulbs/track/Ampoules_short_004.mp3'

    @musicEvents = [
      11.000 # pre-rythmique ! NEW
      12.000 # rythmique
      38.380 # xylophone
      59.480 # violon grave
      66.000 # (violon aigu)
      72.000 # violon grave
      78.000 # (violon aigu)
      84.000 # (violon grave)
      96.000 # final
      120 # end
    ]

    @sfx =
      ropeFalls    : 'CordeTombe_1'
      ropeReleased : 'TireCorde_13'
      ropeGrabbed  : 'Ampoule_ON-1'
      laserOn      : 'Ampoule_Scintille-1_laserGrandit'
      laserOff     : 'Ampoule_Scintille-2_laserDiminue'
      bulbShow1    : 'AmpouleApparait_1-1'
      bulbShow2    : 'AmpouleApparait_1-2'
      liftOut      : 'Ampoule_2-2_ascenseurArrivee'
      liftIn       : 'Ampoule_2-1_ascenseurDepart'
      bulbOn       : 'Ampoule_ON-1'