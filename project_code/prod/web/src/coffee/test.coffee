canvas = document.createElement('canvas')
canvas.setAttribute 'width', '400'
canvas.setAttribute 'height', '400'
canvas.setAttribute 'data-paper-hidpi', ''
document.body.appendChild canvas
paper.setup canvas


mask    = new paper.Group()
content = new paper.Group()
view    = new paper.Layer(mask, content)
count = 0
view.clipped = true


rect = new paper.Path.Rectangle(0, 0, 200, 200)
rect.fillColor = 'blue'
content.addChild(rect)

circle = new paper.Path.Circle
  center: [200, 200],
  radius: 100,
circle.fillColor = 'red'
mask.addChild(circle)

paper.view.onFrame = ->
  offset = Math.sin(++count / 30) * 30
  circle.position.x = offset