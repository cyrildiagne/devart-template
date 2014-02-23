class NiTE
  
  @NUM_JOINTS : 15

  @HEAD           : 0
  @NECK           : 1
  @LEFT_SHOULDER  : 2
  @RIGHT_SHOULDER : 3
  @LEFT_ELBOW     : 4
  @RIGHT_ELBOW    : 5
  @LEFT_HAND      : 6
  @RIGHT_HAND     : 7
  @TORSO          : 8
  @LEFT_HIP       : 9
  @RIGHT_HIP      : 10
  @LEFT_KNEE      : 11
  @RIGHT_KNEE     : 12
  @LEFT_FOOT      : 13
  @RIGHT_FOOT     : 14

  @bones = [
    [@HEAD,           @NECK]
    [@LEFT_SHOULDER,  @RIGHT_SHOULDER]
    [@LEFT_SHOULDER,  @TORSO]
    [@LEFT_SHOULDER,  @LEFT_ELBOW]
    [@LEFT_ELBOW,     @LEFT_HAND]
    [@RIGHT_SHOULDER, @TORSO]
    [@RIGHT_SHOULDER, @RIGHT_ELBOW]
    [@RIGHT_ELBOW,    @RIGHT_HAND]
    [@LEFT_HIP,       @RIGHT_HIP]
    [@LEFT_HIP,       @TORSO]
    [@LEFT_HIP,       @LEFT_KNEE]
    [@LEFT_KNEE,      @LEFT_FOOT]
    [@RIGHT_HIP,      @TORSO]
    [@RIGHT_HIP,      @RIGHT_KNEE]
    [@RIGHT_KNEE,     @RIGHT_FOOT]
  ]


class Joint

  constructor : () ->
    @view = new PIXI.Graphics()
    @view.beginFill(0x000000)
    @view.drawCircle(0, 0, 5)


class Skeleton

  constructor : () ->
    @view = new PIXI.DisplayObjectContainer()
    @gfx = new PIXI.Graphics()
    @view.addChild @gfx
    @width = 0
    @height = 0
    @numJoints = 15
    @joints = []
    @data = []
    @dataRatio = 1
    for i in [0...NiTE.NUM_JOINTS]
      j = new Joint()
      @view.addChild j.view
      @joints.push j

  resize : () ->
    if window.innerWidth > window.innerHeight
      @height = window.innerHeight * 0.5 * window.devicePixelRatio
      @width = @height * @dataRatio
    else
      @width = window.innerWidth * 0.5 * window.devicePixelRatio
      @height = @width * @dataRatio

  toString : () ->
    str = ""
    for i in [0...@data.length] by 3
      str += "#{i/3} - #{@data[i]} - #{@data[i+1]}" + '\n'
    return str

  update : (speed=0.2) ->
    
    for i in [0...@data.length] by 3
      jnt = @joints[i/3]
      jnt.view.position.x += (@data[i] * @width - jnt.view.position.x) * speed
      jnt.view.position.y += (@data[i+1] * @width - jnt.view.position.y) * speed
      # jnt.scale = data[i+2]
    @draw()

  draw : () ->
    @gfx.clear()
    @gfx.lineStyle(2, 0x000000, 1)
    
    for bone in NiTE.bones
      j1p = @joints[ bone[0] ].view.position
      j2p = @joints[ bone[1] ].view.position
      @gfx.moveTo j1p.x, j1p.y
      @gfx.lineTo j2p.x, j2p.y

    
