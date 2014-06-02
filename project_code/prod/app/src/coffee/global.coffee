metamorphoses = [
  'tiroirs'
  'stripes'
  'peaks'
  'bulbs'
  'lockers'
  'tribal'
  'birds'
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
  window.seed = seed
  window.rngs = {}  
  console.log 'set seed ' + seed

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

curtainDown = (callback) ->
  curtain = document.getElementById 'curtain'
  curtain.className = 'down'
  setTimeout ->
    curtain.className = 'down off'
    setTimeout callback, 2000
  , 2000