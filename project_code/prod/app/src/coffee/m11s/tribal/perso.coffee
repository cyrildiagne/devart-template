class mk.m11s.tribal.Perso extends mk.m11s.base.Perso

  setupJoints : (refWidth) ->
    super refWidth
    val = 0
    inc = 2*Math.PI / @joints.length
    @deformInit = false
    for i in [0...@joints.length]
      j = @joints[i]
      j.val = (val+= inc*0.5)
      j.prevX = 0
      j.prevY = 0
      j.ampX = 0
      j.ampY = 0
      # j.initRadius = j.view.radius
    for p in @parts
      p.initColor = p.color

  initDeform : ->
    for j in @joints
      j.prevX = j.x
      j.prevY = j.y
      @deformInit = true

  setPoseFromSkeleton: (skeleton) ->

    if !@joints then return

    for i in [0...skeleton.joints.length]
      @joints[i].x = skeleton.joints[i].view.position.x
      @joints[i].y = skeleton.joints[i].view.position.y
      @joints[i].z = skeleton.joints[i].z

    @morph.update()

    if @items.deform
      if !@deformInit then @initDeform()
      for i in [0...@joints.length]
        j = @joints[i]
        nX = j.x
        j.ampX += (nX - j.prevX) * 2
        j.prevX = nX
        j.x += j.ampX
        j.ampX *= 0.97

        nY = j.y
        j.ampY += (nY - j.prevY) * 2
        j.prevY = nY
        j.y += j.ampY
        j.ampY *= 0.97

      # speed = Math.sqrt(j.ampX*j.ampX + j.ampY*j.ampY)
      # j.view.radius = j.initRadius + speed / 10

    @updateParts()

  updateParts: ->
    super()
    if !@deformInit then return
    for part in @parts
      # if part.name is 'pelvis'
      #   color = mk.Scene::settings.getHexColor 'darkGray'
      # else
        color = new paper.Color part.color
        red = mk.Scene::settings.getHexColor 'red'
        red = new paper.Color red
        # a = 0
        # for j in part.joints
        #   a+= j.ampX + j.ampY
        # color.brightness += Math.abs(a) / (part.joints.length * 2 * 100) * 0.7
        # color.saturation += (1 - color.brightness) * 0.5
        # color.hue += (red.hue - color.hue) * 0.05
        # color.brightness += (red.brightness - color.brightness) * 0.05
        # color.saturation += (red.saturation - color.saturation) * 0.05
      part.setColor red, false#part.color, false
