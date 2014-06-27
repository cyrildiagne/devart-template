metamorphoses = [
  'tiroirs'
  'stripes'
  'thorns'
  'bulbs'
  'lockers'
  'tribal'
  'birds'
  'books'
  'tech'
]

# packages
mk =
  helpers : {}
  m11s :
    base : {}
  skeleton : {}
  sound : {}
  playback : {}
  utils : {}
  physical : {}

for m in metamorphoses
  mk.m11s[m] = {}

# global vars
window.viewport = {width:800, height:1280}
window.metamorphose = null
window.debug = false
window.mouse = {x:0, y:0}

window.jointRatio = 1280 * 0.9

window.seed = null
window.rngs = {}

window.currentTime = 0

setSeed = (seed) ->
  console.log 'set seed ' + seed
  window.seed = seed
  window.rngs = {}  

window.rng = (key) ->
  rng_ = window.rngs[key] || window.rngs[key] = new Math.seedrandom(window.seed+key)
  return rng_()

# global functions
m11Class = (className) =>
  return mk.m11s[metamorphose][className] || mk.m11s.base[className]

setBackgroundColor = (color) ->
  canvas.style.backgroundColor = color

fadeSceneTimeout = -1
fadeScene = (mode, duration=1000, callback) ->
  canvas = document.getElementById 'paperjs-canvas'
  canvas.className = mode
  canvas.style.transition = 'opacity '+duration+'ms ease'
  clearTimeout fadeSceneTimeout
  if callback
    fadeSceneTimeout = setTimeout callback, duration

curtainDown = (fade, callback) ->
  curtain = document.getElementById 'curtain'
  curtain.className = 'down'
  setTimeout ->
    if callback
      callback()
    if fade
      curtain.className = 'down off'
  , 2000
  return

curtainUp = (fade, callback) ->
  delay = 2000
  # delay = if Config::DEBUG then 0 else 1000
  curtain = document.getElementById 'curtain'
  curtain.className = 'down'
  if fade
    setTimeout ->
      curtain.className = ''
      if callback
        callback()
    # , 1000
    , delay
  else 
    curtain.className = ''
    callback()
  return

delayed = (duration, callback) ->
  tween = new TWEEN.Tween().to({}, duration)
   .onComplete(->
      callback()
   ).start window.currentTime

dispatch = (cmd) ->
  window.top.postMessage cmd, '*'

if Config::DEBUG
  window.mouseDownCallbacks = []
  window.addEventListener 'mousedown', ->
    c() for c in window.mouseDownCallbacks
  window.mouseUpCallbacks = []
  window.addEventListener 'mouseup', ->
    c() for c in window.mouseUpCallbacks