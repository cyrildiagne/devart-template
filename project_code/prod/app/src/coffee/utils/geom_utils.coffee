class GeomUtils

  @getTangents : (px, py, cx, cy, radius) ->
    dx = cx - px
    dy = cy - py
    dd = Math.sqrt(dx * dx + dy * dy)
    a = Math.asin(radius / dd)
    b = Math.atan2(dy, dx)
    t = []
    t[0] = [
      cx + radius * Math.sin(b-a),
      cy + radius * -Math.cos(b-a)
    ]
    t[1] = [
      cx + radius * -Math.sin(b+a),
      cy + radius * Math.cos(b+a)
    ]
    return t

  @getCircleTangents : (x1, y1, r1, x2, y2, r2) ->
    # ported from http://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Tangents_between_two_circles
    d_sq = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
    if (d_sq <= (r1-r2)*(r1-r2)) 
      return null
    d = Math.sqrt(d_sq)
    vx = (x2 - x1) / d
    vy = (y2 - y1) / d
    res = [
      [0,0,0,0]
      [0,0,0,0]
      [0,0,0,0]
      [0,0,0,0]
    ]
    i = 0
    for  sign1 in [1..-1] by -2
        c = (r1 - sign1 * r2) / d
        if (c*c > 1.0) then continue
        h = Math.sqrt(Math.max(0.0, 1.0 - c*c))
        for sign2 in [1..-1] by -2
          nx = vx * c - sign2 * h * vy
          ny = vy * c + sign2 * h * vx
          a = res[i++]
          a[0] = x1 + r1 * nx
          a[1] = y1 + r1 * ny
          a[2] = x2 + sign1 * r2 * nx
          a[3] = y2 + sign1 * r2 * ny
    return res