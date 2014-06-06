class mk.m11s.tiroirs.Buttons
  
  constructor : (@physics, @assets) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.pivot = new paper.Point 0,0
    @view.z = 1500

    @buttons = []
    @buttonsToAdd = []

    @maxButtons = 12

  addButton : (p) ->
    bs = ['button1', 'button2', 'button3']
    symbol = @assets[bs.seedRandom 'addbt']
    button = symbol.place()
    radius = (rng('button')*0.3 + 0.7) * 15
    button.buttonScale = radius * 2 / button.bounds.width
    button.scaling = {x:0.1, y:0.1}
    button.growing = true
    @view.addChild button
    pos = 
      x : p.x + (rng('button')-0.5)*2*10
      y : p.y + (rng('button')-0.5)*2*10
    button.body = @physics.addCircle button, pos, radius,
      restitution: 0.5
      friction : 0.01
      force : {x:0, y: -radius*0.0015}

    button.position = pos
    @buttons.push button

  update : (dt) ->
    if @buttonsToAdd.length > 0
      if @buttons.length >= @maxButtons
        bt = @buttons.shift()
        @physics.remove(bt.body)
        bt.remove()
      @addButton @buttonsToAdd.shift()

    for bt in @buttons
      if bt.growing
        d = (bt.buttonScale-bt.scaling.x) * 0.005 * dt
        if Math.abs(d) < 0.005
          bt.growing = false
          bt.scaling = bt.buttonScale
        else
          bt.scaling = bt.scaling.x + d
    return null