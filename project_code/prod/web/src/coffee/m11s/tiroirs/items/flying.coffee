class mk.m11s.tiroirs.Wing

  constructor : (x, y, width, height, speed, color) ->
    @speed = speed
    @path = new paper.Path()
    @path.transformContent = false
    @path.scale 0.25

    @vector = new paper.Point 
      angle: 45
      length: 250
    endVec = new paper.Point
      angle: 45
      length: 150
    @path.segments = [
      [x, y],
      [x+width, y],
      [x, y+height]
    ]
    @path.fillColor = color
    @a = @a2 = 0
  
  update : (time) ->
    a = @a = Math.cos(time) * 65 + 15
    p = @path.segments
    p[1].handleIn  = @vector.rotate(a+140)
    p[1].handleOut = @vector.rotate(a+110)
    p[1].point.y = Math.cos(time+1.4) * 240 + 50
    a2 = @a2 = Math.cos(time-7) * 50 - 10
    p[0].handleOut = @vector.rotate(-a2*1.2-85)
    p[2].handleIn  = @vector.rotate(-a2*1.2-55)

class mk.m11s.tiroirs.Flying

  constructor : (@item, color1, color2) ->
    @wingWidth = 400
    @wingHeight = 20
    @wingSpeed = 7
    @count = 0
    @mouse = new paper.Point()
    @pos = new paper.Point()
    @dest = new paper.Point(-300, -300)
    @velocity = new paper.Point()
    @isFlying = true

    @view = new paper.Group()
    @view.z = 0
    @view.transformContent = false
    @view.position.x = 0
    @view.position.y = 0
    @view.pivot = new paper.Point(0, 0)

    @leftWing = new mk.m11s.tiroirs.Wing 0, 0, @wingWidth, @wingHeight, @wingSpeed, color1
    @leftWing.path.scale -0.8, 0.8
    @leftWing.path.position.x = -@wingWidth*0.5*0.8*0.25
    @view.addChild @leftWing.path

    if @item
      @item.transformContent = false
      @item.position.x = -@item.pivot.x
      @item.position.y = -@item.pivot.y
      @view.addChild @item

    @rightWing = new mk.m11s.tiroirs.Wing 0, 0, @wingWidth, @wingHeight, @wingSpeed, color2
    @view.addChild @rightWing.path

  stop: () ->
    @isFlying = false
    @leftWing.path.remove()
    @rightWing.path.remove()

  update : () ->
    if !@isFlying then return

    if Math.random() > 0.99
      @dest = new paper.Point (Math.random()-0.5)*1000, (Math.random()-0.5)*600 - 200
    @velocity = @dest.subtract(@pos).multiply(0.03)
    if @item
      @item.rotation += (@velocity.x * 4 - @item.rotation) * 0.1

    @pos = @pos.add @velocity
    
    @view.position = @pos.add new paper.Point(0, @leftWing.a2*0.3)
    
    @count += 0.15 + @velocity.length*0.015

    @leftWing.update @count
    @rightWing.update @count