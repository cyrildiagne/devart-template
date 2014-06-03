class mk.m11s.stripes.Settings extends mk.m11s.base.Settings
  
  setupSounds : ->

    @track = 'assets/sounds/stripes/track/stripes_016.mp3'

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