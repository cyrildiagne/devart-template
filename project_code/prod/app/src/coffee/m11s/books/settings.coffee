class mk.m11s.books.Settings extends mk.m11s.base.Settings

  setupAssets : ->
    @assets = [
      'cage'
      'book_closed'
      'book_open'
      'boat'
      'wave1'
      'wave2'
    ]
    for i in [0...@assets.length]
      @assets[i] = 'assets/items/books/' + @assets[i] + '.svg'

  setupSounds : ->
    @track = 'assets/sounds/books/track/Books_short_002.mp3'
    @musicEvents = [
      #apparition maisons
      21.321  # nappe
      #apparition branches
      42.686  # rythmique
      #apparition fleurs / feuilles
      53.346  - 0.5# violon
      #apparition oiseaux
      60.300  # 2eme violon
      # oiseaux rentrent / sortent maisons
      96.010  # break
      # oiseaux rentent dans les maisons
      # lune apparait
      # changement de couleur progressif
      106.671 + 0.3 # reprise rythmique
      # apparition des lucioles
      117.342 # retour violon
      138.669 # 2eme violon
      159.995 # break
      176.046 # fadeout
    ]