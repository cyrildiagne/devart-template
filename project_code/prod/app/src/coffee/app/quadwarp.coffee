class QuadWarp

  constructor: (@dom) ->
    @current = null
    @view = null
    @pts = []
    @dst = []
    @src = []
    @initPts()
    @initPtsView()
    @initRedHighlight()
    window.addEventListener 'resize', @onWindowResize
    @update()

  initPts : ->
    @dst.length = 4
    @src.length = 4
    for i in [0...4]
      @dst[i] = {x:0, y:0}
      @src[i] = {x:0, y:0}
    @src[1].x = @src[2].x = @dst[1].x = @dst[2].x = window.innerWidth
    @src[2].y = @src[3].y = @dst[2].y = @dst[3].y = window.innerHeight

  initPtsView : ->
    @view = document.createElement 'div'
    @view.id = 'quads'
    document.body.appendChild @view
    for i in [0...4]
      point = document.createElement 'div'
      point.className = 'quad'
      point.addEventListener 'mousedown', @onPointMouseDown
      point.id = @pts.length
      @pts.push point
      @view.appendChild point

  initRedHighlight : ->
    window.addEventListener 'mousedown', (e) ->
      e.preventDefault()
      document.body.style.backgroundColor = 'red'
    window.addEventListener 'mouseup', (e) ->
      e.preventDefault()
      document.body.style.backgroundColor = 'black'

  updatePtsView : ->
    for pt in @pts
      pt.style.left = @dst[pt.id].x + 'px'
      pt.style.top  = @dst[pt.id].y + 'px'

  update : ->
    @updatePtsView()
    @perspectiveTransform()

  perspectiveTransform : ->

    a = [[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0]]
    b = [0,0,0,0,0,0,0,0]

    for i in [0...4]
      a[i] = []
      a[i][0]   = a[i+4][3] = @src[i].x
      a[i][1]   = a[i+4][4] = @src[i].y
      a[i][2]   = a[i+4][5] = 1
      a[i][3]   = a[i][4]   = a[i][5] =
      a[i+4][0] = a[i+4][1] = a[i+4][2] = 0
      a[i][6]   = -@src[i].x * @dst[i].x
      a[i][7]   = -@src[i].y * @dst[i].x
      a[i+4][6] = -@src[i].x * @dst[i].y
      a[i+4][7] = -@src[i].y * @dst[i].y
     
      b[i] = @dst[i].x
      b[i+4] = @dst[i].y
      
      bM = []

    for i in [0...b.length]
      bM[i] = [b[i]]
    
    # Matrix Libraries from a Java port of JAMA: A Java Matrix Package, http://math.nist.gov/javanumerics/jama/
    # Developed by Dr Peter Coxhead: http://www.cs.bham.ac.uk/~pxc/
    # Available here: http://www.cs.bham.ac.uk/~pxc/js/
    A = Matrix.create(a)
    B = Matrix.create(bM)
    X = Matrix.solve(A,B)
    
    # Create the resultant transformation 3x3 matrix in a 4x4 matrix for WebKitCSSMatrix 
    matrix = new WebKitCSSMatrix()
    matrix.m11 = X.mat[0][0]
    matrix.m12 = X.mat[3][0]
    matrix.m13 = 0
    matrix.m14 = X.mat[6][0]
    
    matrix.m21 = X.mat[1][0]
    matrix.m22 = X.mat[4][0]
    matrix.m23 = 0
    matrix.m24 = X.mat[7][0]
    
    matrix.m31 = 0
    matrix.m32 = 0
    matrix.m33 = 1
    matrix.m34 = 0
    
    matrix.m41 = X.mat[2][0]
    matrix.m42 = X.mat[5][0]
    matrix.m43 = 0
    matrix.m44 = 1
    
    # Finally apply it
    @dom.style.webkitTransform = matrix

  onPointMouseDown : (e) =>
    @current = e.currentTarget
    window.addEventListener 'mouseup', @onMouseUp
    window.addEventListener 'mousemove', @onMouseMove

  onMouseMove : (e) =>
    @dst[@current.id].x = e.x
    @dst[@current.id].y = e.y
    @update()

  onMouseUp : (e) =>
    @current = null
    window.removeEventListener 'mouseup', @onMouseUp
    window.removeEventListener 'mousemove', @onMouseMove
    document.body.style.backgroundColor = 'black'

  onWindowResize : =>
    @initPts()
    @update()
