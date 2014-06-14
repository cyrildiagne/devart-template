class mk.m11s.stripes.Ball

  constructor : (p, radius) ->
    @view = new paper.Path.Circle p, radius
    @body = null


class mk.m11s.stripes.Balls
  
  constructor : (@physics) ->
    @view = new paper.Group()
    @view.z = 1500

    @balls = []
    @ballsToAdd = []
    @maxBalls = 8

    @ballIntervalTime = 8000

  addBall : (p, radius = 60) ->
    p = p || 
      x : (rng('addball')-0.5) * window.viewport.width
      y : -window.viewport.height * 0.5-radius
    ball = new mk.m11s.stripes.Ball p, radius
    ball.body = @physics.addCircle ball.view, p, radius,
      restitution: 1
      friction : 0.0
      force : {x:0, y: -radius*0.0015}
    ball.position = p
    @balls.push ball
    @view.addChild ball.view

  intervalBall : =>
    radius = 40 + rng('iball')*80
    @ballsToAdd.push {radius:radius}
    if @ballIntervalTime > 1000 + 300
      @ballIntervalTime -= 500
    delayed @ballIntervalTime, @intervalBall

  update : (dt) ->
    if @ballsToAdd.length > 0
      if @balls.length >= @maxBalls
        ball = @balls.shift()
        @physics.remove(ball.body)
        ball.view.remove()
      b = @ballsToAdd.shift()
      @addBall b.pos, b.radius
    return null