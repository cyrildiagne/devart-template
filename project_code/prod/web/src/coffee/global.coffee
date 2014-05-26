metamorphoses = [
  'tiroirs'
  'stripes'
  'peaks'
  'bulbs'
  'tribal'
  'birds'
]

# packages
mk =
  m11s :
    base : {}
  skeleton : {}
  playback : {}
  utils : {}

for m in metamorphoses
  mk.m11s[m] = {}

# global vars
window.viewport = {width:800, height:1280}
window.metamorphose = null
window.debug = false
window.mouse = {x:0, y:0}

window.seed = null
window.rngs = {}  

setSeed = (seed) ->
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