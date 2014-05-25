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


class mk.skeleton.Joint

  constructor : () ->
    @view = new paper.Path.Circle
      center: [0, 0]
      radius: 5
    @view.fillColor = new paper.Color(0,0,0)
    @z = 0

class mk.skeleton.Bone

  constructor : (@j1, @j2) ->
    from = @j1.view.position
    to = @j2.view.position
    @view = new paper.Path.Line( from, to)
    @view.strokeColor = new paper.Color(0,0,0)

  update : ->
    @view.segments[0].point = @j1.view.position
    @view.segments[1].point = @j2.view.position

class mk.skeleton.Skeleton

  constructor : (debug) ->
    @view = new paper.Layer()
    @height = 0
    @width = 0
    @data = []
    @dataRatio = 1
    @setupJoints()
    @setupBones()
    @setDebug debug

  setupJoints : () ->
    @joints = []
    @jointsGrp = new paper.Group()
    for i in [0...NiTE.NUM_JOINTS]
      j = new mk.skeleton.Joint()
      @jointsGrp.addChild j.view
      @joints.push j
    @view.addChild @jointsGrp

  setupBones : () ->
    @bones = []
    @bonesGrp = new paper.Group()
    for bone in NiTE.bones
      b = new mk.skeleton.Bone @joints[bone[0]], @joints[bone[1]]
      @bonesGrp.addChild b.view
      @bones.push b
    @view.addChild @bonesGrp

  setDebug : (@bDebug) ->
    @view.visible = @bDebug

  setDataRatio : (@dataRatio) ->
    @height = window.viewport.height * 0.5
    @width = @height * @dataRatio

  toString : () ->
    str = ""
    for i in [0...@data.length] by 3
      str += "#{i/3} - #{@data[i]} - #{@data[i+1]}" + '\n'
    return str

  update : (speed=0.2) ->
    p = {x:0, y:0}
    for i in [0...@data.length] by 3
      jnt = @joints[i/3]
      jnt.view.position.x += (@data[i] * @width - jnt.view.position.x) * speed
      jnt.view.position.y += (@data[i+1] * @width - jnt.view.position.y) * speed
      jnt.z += (@data[i+2] - jnt.z) * speed
    if @bDebug
      bone.update() for bone in @bones