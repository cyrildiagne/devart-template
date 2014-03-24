metamorphoses = [
  'tribal'
  'peaks'
  'tiroirs'
  'stripes'
  'bulbs'
  'birds'
]

# packages
mk =
  m11s :
    base : {}
  skeleton : {}
  utils : {}

for m in metamorphoses
  mk.m11s[m] = {}

# global vars
window.metamorphose = null
window.debug = false

# global functions
m11Class = (className) =>
  return mk.m11s[metamorphose][className] || mk.m11s.base[className]

setBackgroundColor = (color) ->
  canvas.style.backgroundColor = color