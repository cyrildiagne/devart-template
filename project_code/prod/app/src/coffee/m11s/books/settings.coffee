class mk.m11s.books.Settings extends mk.m11s.base.Settings

  setupAssets : ->
    @assets = [
      'balloon1'
      'balloon2'
      'boat'
      'book_closed'
      'book_open'
      'cage'
      'lighthouse'
      'luggage'
      'rock1'
      'rock2'
      'wave1'
      'wave2'
    ]
    for i in [0...@assets.length]
      @assets[i] = 'assets/items/books/' + @assets[i] + '.svg'

  setupSounds : ->
    @track = 'assets/sounds/books/track/Books_short_002.mp3'
    @musicEvents = [
      1.060 # grelots
      7.380 # grelots
      14.270 # grelots
      21.100 # grelots
      27.090 # violon boucle 1
      44.050 # violon boucle 2
      53.450 # instru
      81.260 # piano
      107.320 # break
      135.080 # end
    ]