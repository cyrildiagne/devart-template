canvas = document.createElement('canvas')
canvas.setAttribute 'width', '400'
canvas.setAttribute 'height', '400'
canvas.setAttribute 'data-paper-hidpi', ''
document.body.appendChild canvas

paper.setup canvas

view = new paper.Layer()
view.transformContent = false

circleGroup = new paper.Group()
view.addChild circleGroup

circle = new paper.Path.Circle
  center: [0, 0]
  strokeColor : "#000000"
  radius: 100
circle.position.x = 100
circle.position.y = 100
circleGroup.addChild circle

# No error if the following 2 lines are commented
# or when using v0.9.15
view.position.x = 200
view.position.y = 200

paper.view.onFrame = ->
  circle.segments[0].point.x = 0