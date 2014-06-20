class mk.m11s.tribal.Flame
  constructor : (x, y, width, height, speed, color) ->
    @speed = speed
    @path = new paper.Path()
    @count = 0
    @time = 0
    @thickness = rng('Flame') * 80 + 10
    @mirrored = false
    @path.segments = [
      [[x, y]],
      [[x+width, y]],
      [[x, y]],
    ]
    @path.fillColor = color
    @a = @a2 = 0
    @vector = new paper.Point({ angle: 45, length: 250 })
    @endVec = new paper.Point({ angle: 45, length: 150 })
  
  update : ->
    @count++
    @time += @speed
    # @path.style.fillColor.hue += 2
    @path.style.fillColor.saturation -= 0.01
    @path.style.fillColor.brightness += 0.005
    a = @a = Math.cos(@time) * 65 + 15
    p = @path.segments
    p[1].handleIn  = @vector.rotate(a+100 + @thickness*0.5)
    p[1].handleOut = @vector.rotate(a+100 - @thickness*0.5)
    p[1].point.y = Math.cos(@time+1.4) * 130
    a2 = @a2 = Math.cos(@time+1.5) * 50 - 10
    p[0].handleOut = @vector.rotate(-a2*1.2-60 - @thickness*0.5)
    p[2].handleIn  = @vector.rotate(-a2*1.2-40 + @thickness*0.5)

class mk.m11s.tribal.Fire

  constructor:(@colors) ->
    @view = new paper.Group()
    @view.z = 99999
    @view.transformContent = false
    @view.scale(0.5)
    @view.pivot = new paper.Point(0, 0)

    @pos = new paper.Point()
    @velocity = new paper.Point()
    @flames = []
    @numFlames = 9

    @rngk = 'Fire'
    @timeSinceFlame = 0
    @timeBeforeNextFlame = 0

    @maxCount = 40
    @growSpeed = 1.035
    @initScale = 0.5
    @minSpeed = 0.05
    @riseSpeed = 10

    @amp = 0
    @wind = 1

    @sfx = mk.Scene::sfx.play 'fireloop'
    @sfx.volume(0) if @sfx

  clean : ->
    @sfx.stop()

  addFlame : ->
    rngk = @rngk + 'addFlame'
    flameWidth = 400
    flameHeight = 20
    flameSpeed = rng(rngk) * 0.1 + @minSpeed
    # color = new paper.Color
    #   hue : 360
    #   saturation : 0.75
    #   brightness : 1
    color = '#'+@colors.seedRandom(rngk).toString(16)
    
    flame = new mk.m11s.tribal.Flame 0, 10, flameWidth, flameHeight, flameSpeed, color
    flame.path.transformContent = false
    flame.path.pivot = new paper.Point(0,0)
    flame.path.rotate(-90)
    flame.path.scale(rng(rngk)*@initScale+0.2, rng(rngk)*@initScale+0.1)
    if rng(rngk)>0.5
      flame.path.scale(-1, 1)

    flame.path.fullySelected = @view.fullySelected
    
    @view.addChild(flame.path)
    @flames.push(flame)

  setAmp : (ratio) ->
    @amp = ratio
    @maxCount = 15 + ratio * 30
    @growSpeed = 1.030 + ratio*0.008
    @initScale = ratio * 0.5 + 0.1
    @minSpeed = 0.02 + ratio * 0.06
    @riseSpeed = 10 + ratio * 5

    @sfx.volume(Math.min(1, 0.2 + ratio*0.5)) if @sfx

  update: (dt) ->
    i = 0
    @view.rotation = @wind * 20
    for f in @flames
      f.update()
      f.path.position.x -= f.path.position.y * @wind * 0.05
      if f.count > @maxCount
        f.path.position.y -= f.time*2 + @riseSpeed
        f.path.scale(0.96)
        if f.path.scaling.y < 0.5
          f.remove = true
      else
        f.path.scale @growSpeed

    i = @flames.length-1
    while i >= 0
      if @flames[i].remove
        @flames[i].path.remove()
        @flames.splice(i, 1)
      i--

    @timeSinceFlame+=dt
    if @timeSinceFlame > @timeBeforeNextFlame
      @timeSinceFlame -= @timeBeforeNextFlame
      @timeBeforeNextFlame = rng(@rngk + 'newFlame') * 60 + 20
      @addFlame()