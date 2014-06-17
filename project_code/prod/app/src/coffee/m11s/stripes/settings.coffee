class mk.m11s.stripes.Settings extends mk.m11s.base.Settings
  
  setupSounds : ->

    @track = 'assets/sounds/stripes/track/stripes_016.mp3'

    @musicEvents = [
        7.240 # rythmique
        22.340 # piano
        37.200 # xylophone : boucle 1
        52.160 # xylophone : boucle 2
        67.170 # percu brève
        67.290 # violon
        71.040 # (percu brève)
        71.160 # (violon)
        74.420 # (percu brève)
        75.030 # (violon)
        78.290 # (percu brève)
        78.400 # (violon)
        82.150 # xylophone
        112.120 # end
    ]