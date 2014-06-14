rngi = (key, min, max) -> min + Math.floor(rng(key)*(max+1-min))

Array::last   = -> @[@length - 1]
Array::random = -> @[Math.floor(Math.random()*@length)]
Array::seedRandom = (key) -> @[Math.floor(rng(key)*@length)]