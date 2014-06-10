class mk.m11s.tribal.Shadow

  constructor : ( @head, @leftFoot, @rightFoot) ->

    symbol = mk.Scene::assets['shadow']
    @svg = symbol.place()
    @svg.transformContent = false
    @svg.pivot = new paper.Point 0,@svg.bounds.height * 0.5

    @mh = @svg.bounds.height * 0.5

    @base = new paper.Path()
    @base.fillColor = mk.Scene::settings.getHexColor('blue')
    @base.add [0,0] for i in [0...4]

    @lightSrcX = 100

    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0
    @view.addChild @base
    @view.addChild @svg

  update : (dt) ->
    dist = @head.x - @lightSrcX
    # center = window.viewport.width * 0.5

    @svg.scaling = 0.4 - (@head.y / window.viewport.height) * 4
    # console.log @svg.scaling

    mw = @svg.bounds.width * 0.5
    # mh = @svg.bounds.height * 0.5

    @svg.position.x = window.viewport.width*0.5+dist*2
    # @svg.position.y =  mh * @svg.scaling.x

    @base.segments[0].point.x = @rightFoot.x
    @base.segments[0].point.y = @rightFoot.y

    @base.segments[1].point.x = @leftFoot.x
    @base.segments[1].point.y = @leftFoot.y

    @base.segments[2].point.x = @svg.position.x - mw
    @base.segments[2].point.y = @mh - 1

    @base.segments[3].point.x = @svg.position.x + mw
    @base.segments[3].point.y = @mh - 1