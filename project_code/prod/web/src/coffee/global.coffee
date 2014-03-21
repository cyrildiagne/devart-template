# packages
mk =
  m11s :
    base : {}
    tiroirs : {}
    bulbs : {}
    peaks : {}
    tribal : {}
    stripes : {}
  skeleton : {}
  utils : {}

# global vars
window.metamorphose = null
window.debug = false

# global functions
m11Class = (className) =>
  return mk.m11s[metamorphose][className] || mk.m11s.base[className]