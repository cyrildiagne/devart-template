class mk.m11s.books.Cage
  
  constructor : (hand) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0

    @symbol = mk.Scene::assets['cage'].place()
    @view.addChild @symbol

    @view.pivot = new paper.Point 0, -@view.bounds.width*0.5 - 20

    @follower = new mk.helpers.JointFollower @view, hand, 200

    @light = null
    @setupLight()

    @scaleIn @view

  scaleIn : (v) ->
    v.scaling = 0.01
    v.visible = true
    tween = new TWEEN.Tween({ scale: 0.01 })
    .to({ scale: 1 }, 1000)
    .onUpdate(->
       v.scaling = @scale
    )
    .start window.currentTime

  scaleOut : (v) ->
    tween = new TWEEN.Tween({ scale: v.scaling.x })
    .to({ scale: 0.01 }, 1000)
    .onUpdate(->
       v.scaling = @scale
    )
    .onComplete(->
      v.visible = false
    )
    .start window.currentTime

  setupLight : ->
    cream = mk.Scene::settings.getPaperColor 'cream'
    cream.alpha = 0.8
    @light = new paper.Group()
    c = new paper.Path.Circle
      center : [0,0]
      radius : 10
      fillColor : cream
    @light.addChild c

    c2 = new paper.Path.Circle
      center : [0,0]
      radius : 150
      fillColor : cream.clone()
    c2.fillColor.alpha = 0.4
    @light.addChild c2

    @light.visible = false

    @view.addChild @light

  remove : (callback) ->
    @scaleOut @view
    delayed 1200, callback

  switchLightOn : () ->
    @scaleIn @light

  switchLightOff : () ->
    @scaleOut @light

  update : (dt) ->
    @follower.update()