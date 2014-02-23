class Plop

  constructor : (@textures, x, y) ->
    @movie = null
    @animated = Math.random() < params.animatedRatio
    @angle = Math.random()*Math.PI*2
    @dist = Math.random()*params.radius
    @speed = Math.random() * 0.15 + 0.02
    @offset =
      x: Math.cos(@angle) * @dist
      y: Math.sin(@angle) * @dist
    @setupMovie(x, y)

  setupMovie : (x, y) ->
    if @animated
      @movie = new PIXI.MovieClip(@textures)
    else
      @movie = new PIXI.Sprite(@textures[ Math.floor(Math.random()*@textures.length) ])
    @movie.position.x = x + @offset.x
    @movie.position.y = y + @offset.y
    @movie.anchor.x = 0.5
    @movie.anchor.y = 0.5
    @movie.rotation = Math.random() * Math.PI
    @movie.animationSpeed = 0.2 + Math.random()*0.8
    @movie.tint = params.colors[ Math.floor(Math.random()*params.colors.length)]

  setPosition : (x, y) ->
    @movie.position.x = x + @offset.x
    @movie.position.y = y + @offset.y

  move : (x, y) ->
    @angle += @speed * 0.2
    @offset =
      x: Math.cos(@angle) * @dist
      y: Math.sin(@angle) * @dist
    @movie.position.x += (x+@offset.x - @movie.position.x) * @speed
    @movie.position.y += (y+@offset.y - @movie.position.y) * @speed
    @movie.rotation += @speed * 0.2


class Plops

  constructor : () ->
    @view = new PIXI.DisplayObjectContainer

    @plopsArr = null
    @plopTextures = []

    for i in [0..39]
      id = '000' + i
      id = id.substr(id.length-4)
      texture = PIXI.Texture.fromFrame 'plop/'+id
      @plopTextures.push(texture)

    r = window.devicePixelRatio

    @plopsArr = []

    for i in [0...params.numParticles]
      plop = new Plop(@plopTextures, 0, 0)
      if plop.animated
        plop.movie.gotoAndPlay(i%26)
      @view.addChild(plop.movie)
      @plopsArr.push(plop)

  setPosition : (position) ->
    for plop in @plopsArr
      plop.setPosition position.x, position.y

  update : (position) ->
    for plop in @plopsArr
      plop.move position.x, position.y
