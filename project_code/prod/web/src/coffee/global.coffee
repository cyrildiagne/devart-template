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
window.viewport = null
window.metamorphose = null
window.debug = false

stageWidth = ->
  return window.viewport.width

stageHeight = ->
  return window.viewport.height

toPt = (px) ->
  vp = window.viewport
  if vp.width > vp.height
    ratio = 1000 / window.viewport.height
  else
    ratio = 1400 / window.viewport.width
  return px * ratio

toPx = (pt) ->
  vp = window.viewport
  if vp.width > vp.height
    ratio = window.viewport.height / 1000
  else
    ratio = window.viewport.width / 1400
  return pt * ratio

# global functions
m11Class = (className) =>
  return mk.m11s[metamorphose][className] || mk.m11s.base[className]

setBackgroundColor = (color) ->
  canvas.style.backgroundColor = color