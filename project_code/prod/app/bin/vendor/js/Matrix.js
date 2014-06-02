/* ========================= LUDecomposition ==========================

Description: Javascript routines to decompose a matrix A into a lower
  and an upper triangular matrix, L and U, so that L*U = A (possibly
  with its rows re-ordered).  Stored as methods of the global variable
  LUDecomposition.
Acknowledgement: This Javascript code is based on the source code of
  JAMA, A Java Matrix package (http://math.nist.gov/javanumerics/jama/),
  which states "Copyright Notice This software is a cooperative product
  of The MathWorks and the National Institute of Standards and
  Technology (NIST) which has been released to the public domain.
  Neither The MathWorks nor NIST assumes any responsibility whatsoever
  for its use by other parties, and makes no guarantees, expressed
  or implied, about its quality, reliability, or any other
  characteristic."
Author: Peter Coxhead (http://www.cs.bham.ac.uk/~pxc/)
Copyright: The conversion of the JAMA source to Javascript is
  copyright Peter Coxhead, 2008, and is released under GPLv3
  (http://www.gnu.org/licenses/gpl-3.0.html).
Last Revision: 9 Dec 2008
*/
var version = 'LUDecomposition 1.00';
/*

Uses Matrix.js.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

LU Decomposition (from the JAMA package)

For an m-by-n matrix A with m >= n, the LU decomposition is an m-by-n
unit lower triangular matrix L, an n-by-n upper triangular matrix U,
and a permutation vector piv of length m so that A(piv,:) = L*U.
If m < n, then L is m-by-m and U is m-by-n.

The LU decomposition with pivoting always exists, even if the matrix is
singular, so the constructor will never fail.  The primary use of the
LU decomposition is in the solution of square systems of simultaneous
linear equations.  This will fail if isNonsingular() returns false.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

***NOTE*** The functions in LUDecomposition.js should NOT normally be
  used directly.  Their main use to provide 'services' to the functions
  in Matrix.js.

LUDecomposition.create(mo): given a Matrix object mo, it returns an
  object from which L, U and piv can be accessed.

LUDecomposition.restore(mo,lud): returns a new Matrix object comprised
  of the rows of the Matrix object mo restored to the order given in
  the pivot of the LUDecomposition object lud.

LUDecomposition.isNonsingular(lud): given an LUDecomposition object lud, it
  determines whether the matrix from which it was derived is singular or
  not. The value of Matrix.getEPS() is used as the smallest non-zero
  number.

LUDecomposition.getL(lud): given an LUDecomposition object lud, it creates
  and returns the lower triangular factor, L, as a Matrix object.
LUDecomposition.getU(lud): given an LUDecomposition object lud, it creates
  and returns the upper triangular factor, U, as a Matrix object.

LUDecomposition.det(lud): given an LUDecomposition object lud, it returns
  the determinant of the matrix from which it was derived. The value of
  Matrix.getEPS() is used as the smallest non-zero number.

LUDecomposition.solve(lud,bmat): if the LUDecomposition object lud is derived
  from the matrix A, and the Matrix object bmat represents the matrix b, then
  this function solves the matrix equation A*x = b, returning x as a Matrix
  object.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

var LUDecomposition = new createLUDecompositionPackage();
function createLUDecompositionPackage()
{
this.version = version;

var abs = Math.abs;   // local synonym
var min = Math.min;   // local synonym

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Private function to check that an argument is a Matrix object.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function _chkMatrix(fname,argno,arg)
{ if (!arg.isMatrix)
  { writeln('***ERROR: in LUDecomposition.'+fname+': argument '+argno+
            ' is not a Matrix.');
    throw null;
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Private function to check that an argument is an LUDecomposition object
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function _chkLUDecomposition(fname,argno,arg)
{ if (!arg.isLUDecomposition)
  { writeln('***ERROR: in LUDecomposition.'+fname+': argument '+argno+
            ' is not an LUDecomposition.');
    throw null;
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.create(mo): given a Matrix object mo, it returns an
//   object from which L, U and piv can be accessed.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.create = function (mo)
{ _chkMatrix('create',1,mo);
  var m;        // row dimension
  var n;        // col dimension
  // Use a "left-looking", dot-product, Crout/Doolittle algorithm.
  var matLU = Matrix.create(mo.mat);
  var LU = matLU.mat;
  m = mo.m;
  n = mo.n;
  var piv = new Array();
  for (var i = 0; i < m; i++) piv[i] = i;
  var pivsign = 1;
  var LUrowi;
  var LUcolj = new Array(m);
  // outer loop
  for (var j = 0; j < n; j++)
  { // make a copy of the j-th column to localize references
    for (var i = 0; i < m; i++) LUcolj[i] = LU[i][j];
    // apply previous transformations
    for (var i = 0; i < m; i++)
    { LUrowi = LU[i];
      // most of the time is spent in the following dot product
      var kmax = min(i,j);
      var s = 0.0;
      for (var k = 0; k < kmax; k++) s += LUrowi[k]*LUcolj[k];
      LUrowi[j] = LUcolj[i] -= s;
    }
    // find pivot and exchange if necessary.
    var p = j;
    for (var i = j+1; i < m; i++)
    { if (abs(LUcolj[i]) > abs(LUcolj[p])) p = i;
    }
    if (p != j)
    { for (var k = 0; k < n; k++)
      { var t = LU[p][k];
        LU[p][k] = LU[j][k];
        LU[j][k] = t;
      }
      var k = piv[p];
      piv[p] = piv[j];
      piv[j] = k;
      pivsign = -pivsign;
    }
    // compute multipliers
    if (j < m && LU[j][j] != 0.0)
    { for (var i = j+1; i < m; i++) LU[i][j] /= LU[j][j];
    }
  }
  // now create and return the object with the results
  var lud = new Object();
  lud.LU = LU;
  lud.m = m;
  lud.n = n;
  lud.pivsign = pivsign;
  lud.piv = piv;
  lud.isLUDecomposition = true;
  return lud;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.restore(mo,lud): returns a new Matrix object comprised
//   of the rows of the Matrix object mo restored to the order given in the
//   pivot of the LUDecomposition object lud.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.restore = function (mo,lud)
{ _chkMatrix('restore',1,mo);
  _chkLUDecomposition('restore',2,lud);
  var res = Matrix.create(mo.m,mo.n);
  var r = lud.piv;
  for (var i = 0; i < mo.m; i++)
    for (var j = 0; j < mo.n; j++)
      res.mat[r[i]][j] = mo.mat[i][j];
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//LUDecomposition.isNonsingular(lud): given an LUDecomposition object lud, it
//  determines whether the matrix from which it was derived is singular or
//  not. The value of Matrix.getEPS() is used as the smallest non-zero
//  number.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.isNonsingular = function (lud)
{ _chkLUDecomposition('isNonsingular',1,lud);
  var eps = Matrix.getEPS();
  with (lud)
  { for (var j = 0; j < n; j++)
    { if (abs(LU[j][j]) < eps) return false;
    }
  }
  return true;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.getL(lud): given an LUDecomposition object lud, it creates
//   and returns the lower triangular factor, L, as a Matrix object.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.getL = function (lud)
{ _chkLUDecomposition('getL',1,lud);
  var xm = lud.m;
  var xn = (lud.m >= lud.n)? lud.n : lud.m;
  var X = Matrix.create(xm,xn);
  var L = X.mat;
  with (lud)
  { for (var i = 0; i < xm; i++)
    { for (var j = 0; j < xn; j++)
      { if (i > j) L[i][j] = LU[i][j];
        else if (i == j)  L[i][j] = 1.0;
        else L[i][j] = 0.0;
      }
    }
  }
  return X;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.getU(lud): given an LUDecomposition object lud, it creates
//   and returns the upper triangular factor, U, as a Matrix object.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.getU = function (lud)
{ _chkLUDecomposition('getU',1,lud);
  var xm = (lud.m >= lud.n)? lud.n : lud.m;
  var xn = lud.n;
  var X = Matrix.create(xm,xn);
  var U = X.mat;
  with (lud)
  { for (var i = 0; i < xm; i++)
    { for (var j = 0; j < xn; j++)
      { if (i <= j) U[i][j] = LU[i][j];
        else U[i][j] = 0.0;
      }
    }
  }
  return X;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.det(lud): given an LUDecomposition object lud, it
//   returns the determinant of the matrix from which it was derived. The
//   value of Matrix.getEPS() is used as the smallest non-zero number.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.det = function (lud)
{ _chkLUDecomposition('det',1,lud);
  var eps = Matrix.getEPS();
  if (lud.m != lud.n)
  { writeln('***ERROR: in LUDecomposition.det: argument 1 is not square.');
     throw null;
  }
  var d = lud.pivsign;
  with (lud)
  { for (var j = 0; j < n; j++)
    { var val = LU[j][j];
      d *= LU[j][j];
      if (abs(d) < eps) return 0;
    }
  }
  return d;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// _arrange(mo,r): a private function which returns a new Matrix object
//  comprisedof the rows of the Matrix object mo arranged according to
//  the values in the array r.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function _arrange(mo,r)
{ with (mo)
  { var res = Matrix.create(m,n);
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        res.mat[i][j] = mat[r[i]][j];
  }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// LUDecomposition.solve(lud,bmat): if the LUDecomposition object lud is
//   derived from the matrix A, and the Matrix object bmat represents the
//   matrix b, then this function solves the matrix equation A*x = b,
//   returning x as a Matrix object.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.solve = function (lud,bmat)
{ _chkMatrix('solve',2,bmat);
  _chkLUDecomposition('solve',1,lud);
  if (bmat.m != lud.m)
  { writeln('***ERROR: in LUDecomposition.solve: matrix row dimensions do not agree.');
    throw null;
  }
  if (!this.isNonsingular(lud))
  { writeln('***ERROR: in LUDecomposition.solve: matrix is singular.');
    throw null;
  }
  // copy right hand side with pivoting
  var nx = bmat.n;
  var Xmat = _arrange(bmat,lud.piv);
  var X = Xmat.mat;
  // solve L*Y = B(piv,:)
  with (lud)
  { for (var k = 0; k < n; k++)
    { for (var i = k+1; i < n; i++)
      { for (var j = 0; j < nx; j++)
        { X[i][j] -= X[k][j]*LU[i][k];
        }
      }
    }
    // solve U*X = Y
    for (var k = n-1; k >= 0; k--)
    { for (var j = 0; j < nx; j++)
      { X[k][j] /= LU[k][k];
      }
      for (var i = 0; i < k; i++)
      { for (var j = 0; j < nx; j++)
        { X[i][j] -= X[k][j]*LU[i][k];
        }
      }
    }
  }
  return Xmat;
}

}





















/*  ======================================= MATRICES =====================================

Description: Javascript routines to handle matrices (2D arrays).
  Stored as methods of the global variable Matrix.
Author: Peter Coxhead (http://www.cs.bham.ac.uk/~pxc/)
Copyright: Peter Coxhead, 2008-2009; released under GPLv3
  (http://www.gnu.org/licenses/gpl-3.0.html).
Last Revision: 9 July 2009
*/
var version = 'Matrix 1.01';
/*

Uses IOUtils.js, LUDecomposition.js, QRDecomposition.js, EVDecomposition.js.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The useful fields of a Matrix object are:
  m    number of rows
  n    number of columns
  mat  the matrix as an array of m entries, each being arrays of n entries.

Matrix.getEPS(): in any matrix calculation, an absolute value less than Matrix.getEPS()
  is replaced by 0. The default value is 2^-40 (~9e-13). Set to a different value if you
  want more or less precision.
Matrix.setEPS(newEPS): see above.

Matrix.create(arr): creates a Matrix object to represent the two-dimensional
  array arr. The value of arr is copied.
Matrix.create(m,n): creates a Matrix object to represent an m-by-n matrix,
  whose values are undefined.

Matrix.identity(m,n): returns a Matrix object corresponding to the m-by-n identity matrix.
Matrix.unit(m,n): returns a Matrix object corresponding to the m-by-m unit matrix.
Matrix.random(m,n): returns a Matrix object corresponding to a m-by-n matrix with
  random values such that 0 <= result[i][j] < 1.

Matrix.copy(mo,fromRow,fromCol,m,n): given an Matrix object mo returns a copy
  of the submatrix whose first entry is at [fromRow][fromCol] and which is of size
  m-by-n.

Matrix.transpose(mo): returns a Matrix object corresponding to the transpose of the
  Matrix object mo.
  
Matrix.diagOf(mo): returns the diagonal of a Matrix object mo as a column vector (i.e.
  an l-by-1 Matrix object), where l is the minimum of the number of rows and columns of
  mo.
Matrix.diag(mo): mo must be a column vector, i.e. an m-by-1 Matrix object; the
  function then returns an m-by-m Matrix object with this vector as its diagonal
  and all off-diagonal elements set to 0.

Matrix.max(mo): returns the largest entry in the matrix.
Matrix.min(mo): returns the smallest entry in the matrix.

Matrix.scale(mo,scalar): returns a Matrix object corresponding to the Matrix object mo
  scaled by scalar.

Matrix.add(mo1,mo2): returns the matrix addition of the Matrix objects mo1 and mo2.
Matrix.sub(mo1,mo2): returns the matrix subtraction of the Matrix objects mo1 and mo2.
Matrix.mult(mo1,mo2): returns the matrix multiplication of the Matrix objects mo1 and mo2.

Matrix.map(f,mo): returns a Matrix object obtained by applying the function f to
  each element of the Matrix object mo.  f must be a function of one argument.
Matrix.combine(f,mo1,mo2): returns a Matrix object obtained by applying the function f
  to each element of the Matrix object mo1 and the corresponding element of the Matrix
  element mo2 (which must be of the same dimension).  f must be a function of two
  arguments.

Matrix.trace(mo): returns the trace of the Matrix object mo.
Matrix.det(mo): returns the determinant of the Matrix object mo, which must be square.

Matrix.inverse(mo): returns the inverse of the Matrix object mo.

Matrix.solve(A,B): solves the matrix equation A*X = B, returning x as a Matrix object.
  If A is square, the solution is exact; if A has more rows than columns, the solution
  is least squares. (No solution is possible if A has fewer rows than columns.)
  Uses LUDecomposition.js and QEDecomposition.js.
  
Matrix.eigenstructure(mo): given a square Matrix object mo, returns an object whose
   fields contain the eigenvectors and eigenvalues. The fields are as follows:
   V    the columnwise eigenvectors as a Matrix object
   lr   the real parts of the eigenvalues as an array
   li   the imaginary parts of the eigenvalues as an array
   L    the block diagonal eigenvalue matrix as a Matrix object
   isSymmetric   whether the matrix is symmetric or not (boolean).

Matrix.display(mo,dp): displays the Matrix object mo using dp decimal places. If dp is
  omitted, the default in IOUtils.js is used.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Example
-------

(Also uses IOUtils.js, EVDecomposition.js and LUDecomposition.js.)

with (Matrix)
{ var A = create([[1,2,4],[8,2,1],[-2,3,0]]);
  println('A');
  display(A,0);

  var Ainv = inverse(A);
  nl(); println('inverse(A)*A');
  display(mult(Ainv,A));
  nl(); println('inverse(A)*A - I');
  display(sub(mult(Ainv,A),identity(A.n,A.m)));

  var B = random(3,2);
  nl(); println('B');
  display(B);
  var X = solve(A,B);
  nl(); println('X obtained by solving A*X = B');
  display(X);
  nl(); println('A*X - B');
  display(sub(mult(A,X),B));

  var es = eigenstructure(A);

  nl(); println('V (eigenvectors for A)');
  display(es.V);
  nl(); println('L (block diagonal eigenvalue matrix for A)');
  display(es.L);
  nl(); println('A*V - V*L');
  display(sub(mult(A,es.V),mult(es.V,es.L)));
  nl(); println('A - V*L*inverse(V)');
  display(sub(A,mult(es.V,mult(es.L,inverse(es.V)))));
}

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

var Matrix = new createMatrixPackage();
function createMatrixPackage()
{
this.version = version;

var abs = Math.abs; // local synonym

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Any number whose absolute value is < EPS is taken to be 0.
// Matrix.getEPS(): returns the current value of EPS.
// Matrix.setEPS(): changes the current value of EPS.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
var EPS = Math.pow(2,-40);
this.getEPS = function ()
{ return EPS;
}
this.setEPS = function (newEPS)
{ EPS = newEPS;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// _chkNum is a private function used in replacing small values by 0.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function _chkNum(x)
{ return (abs(x) < EPS)? 0 : x;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// _chkMatrix is a private function which checks that argument i of
//   the function whose name is fname and whose value is arg is a
//   Matrix object.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function _chkMatrix(fname,i,arg)
{ if(!arg.isMatrix)
  { throw '***ERROR: Argument '+i+' of Matrix.'+fname+
          ' is not a Matrix; its value is "'+arg+'".';
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.create(arr): creates a Matrix object to represent the two-dimensional
//   array arr. The contents of arr are copied.
// Matrix.create(m,n): creates a Matrix object to represent an m x n matrix,
//   whose values are undefined.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.create = function (a1,a2)
{ // check args
  var isMatArg1 = a1 instanceof Array;
  if (!isMatArg1 && (typeof a1 != 'number'))
  { throw '***ERROR: in Matrix.create: argument 1 is not an array or a number.';
  }
  if (isMatArg1 && a2 != null)
  { throw '***ERROR: in Matrix.create: argument 1 is an array but argument 2 is also present.';
  }
  if (isMatArg1) return _createMatrixfromArray(a1);
  else return _createMatrixfromDimensions(a1,a2);
}
function _createMatrixfromArray(arr)
{ var m = arr.length;
  for (var i = 0; i < m; i++)
  { if (!(arr[i] instanceof Array))
    { throw '***ERROR: in Matrix.create: argument 1 is not a 2D array.';
    }
    if (arr[i].length != arr[0].length)
    { throw '***ERROR: in Matrix.create: argument 1 has different length rows.';
    }
  }
  var n = arr[0].length;
  var res = new Array(m);
  for (var i = 0; i < m; i++)
  { res[i] = new Array(n);
    for (var j = 0; j < n; j++) res[i][j] = _chkNum(arr[i][j]);
  }
  var x = new Object();
  x.m = m;
  x.n = n;
  x.mat = res;
  x.isMatrix = true;
  return x;
}
function _createMatrixfromDimensions(m,n)
{ var arr = new Array(m);
  for (var i = 0; i < m; i++) arr[i] = new Array(n);
  var x = new Object();
  x.m = m;
  x.n = n;
  x.mat = arr;
  x.isMatrix = true;
  return x;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.identity(m,n): returns a Matrix object corresponding to the m-by-n identity
//   matrix.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.identity = function (m,n)
{ var res = _createMatrixfromDimensions(m,n);
  with (res)
  { for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = 0;
    for (var i = 0; i < Math.min(m,n); i++) mat[i][i] = 1;
  }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.unit(m,n): returns a Matrix object corresponding to the m-by-n unit matrix.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.unit = function (m,n)
{ var res = _createMatrixfromDimensions(m,n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = 1;
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.random(m,n): returns a Matrix object corresponding to a m-by-n matrix with
//   random values such that 0 <= result[i][j] < 1.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.random = function (m,n)
{ var res = _createMatrixfromDimensions(m,n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(Math.random());
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.copy(mo,fromRow,fromCol,m,n): given an Matrix object mo returns a copy
//   of the submatrix whose first entry is at [fromRow][fromCol] and which is of size
//   m by n.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.copy = function (mo,fromRow,fromCol,m,n)
{ _chkMatrix('copy',1,mo);
  var res = _createMatrixfromDimensions(m,n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = mo.mat[i + fromRow][j + fromCol];
  return res;      
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.transpose(mo): returns a Matrix object corresponding to the transpose of the
//   Matrix object mo.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.transpose = function (mo)
{ _chkMatrix('transpose',1,mo);
  var res = _createMatrixfromDimensions(mo.n,mo.m);
  with (res)
  { for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = mo.mat[j][i];
  }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.diagOf(mo): returns the diagonal of a Matrix object mo as a column vector (i.e.
//   an l-by-1 Matrix object), where l is the minimum of the number of rows and columns of
//   mo.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.diagOf = function (mo)
{ _chkMatrix('diagOf',1,mo);
  var res = _createMatrixfromDimensions(Math.min(mo.m,mo.n),1);
  with (res)
  { for (var i = 0; i < m; i++)
      mat[i][0] = mo.mat[i][i];
  }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.diag(mo): mo must be a column vector, i.e. an m-by-1 Matrix object; the
//   function then returns an m-by-m Matrix object with this vector as its diagonal
//   and all off-diagonal elements set to 0.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.diag = function (mo)
{ _chkMatrix('diag',1,mo);
  if (mo.n != 1)
  { throw '***ERROR: in Matrix.diag: argument 1 is not a column vector.';
  }
  var res = Matrix.identity(mo.m,mo.m);
  with (res)
  { for (var i = 0; i < m; i++)
      mat[i][i] = mo.mat[i][0];
  }
  return res;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.max(mo): returns the largest entry in the matrix.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.max = function (mo)
{ _chkMatrix('max',1,mo);
  with (mo)
  { var res = mat[0][0];
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        if (mat[i][j] > res) res = mat[i][j];
  }
  return _chkNum(res);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.min(mo): returns the smallest entry in the matrix.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.min = function (mo)
{ _chkMatrix('min',1,mo);
  with (mo)
  { var res = mat[0][0];
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        if (mat[i][j] < res) res = mat[i][j];
  }
  return _chkNum(res);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.scale(mo,scalar): returns a Matrix object corresponding to the Matrix object mo
//   scaled by scalar.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.scale = function (mo,scalar)
{ _chkMatrix('scale',1,mo);
  var res = _createMatrixfromArray(mo.mat);
  with (res)
  { for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(scalar * mat[i][j]);
  }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.add(mo1,mo2): returns the matrix addition of the Matrix objects mo1 and mo2.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.add = function (mo1,mo2)
{ _chkMatrix('add',1,mo1);
  _chkMatrix('add',2,mo2);
  if (mo1.m != mo2.m || mo1.n != mo2.n)
  { throw '***ERROR: in Matrix.add: matrix dimensions don\'t match.';
  }
  var res = _createMatrixfromDimensions(mo1.m,mo1.n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(mo1.mat[i][j] + mo2.mat[i][j]);
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.sub(mo1,mo2): returns the matrix subtraction of the Matrix objects mo1 and mo2.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.sub = function (mo1,mo2)
{ _chkMatrix('sub',1,mo1);
  _chkMatrix('sub',2,mo2);
  if (mo1.m != mo2.m || mo1.n != mo2.n)
  { throw '***ERROR: in Matrix.sub: matrix dimensions don\'t match.';
  }
  var res = _createMatrixfromDimensions(mo1.m,mo1.n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(mo1.mat[i][j] - mo2.mat[i][j]);
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.mult(mo1,mo2): returns the matrix multiplication of the Matrix objects mo1 and
//   mo2.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.mult = function (mo1,mo2)
{ _chkMatrix('mult',1,mo1);
  _chkMatrix('mult',2,mo2);
  if (mo1.n != mo2.m)
  { throw '***ERROR: in Matrix.mult: matrix dimensions don\'t match.';
  }
  var res = _createMatrixfromDimensions(mo1.m,mo2.n);
  var temp;
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
      { temp = 0;
        for (var k = 0; k < mo1.n; k++)
          temp += mo1.mat[i][k] * mo2.mat[k][j];
        mat[i][j] = _chkNum(temp);
      }
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.map(f,mo): returns a Matrix object obtained by applying the function f to
//   each element of the Matrix object mo.  f must be a function of one argument.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.map = function (f,mo)
{ _chkMatrix('map',2,mo);
  var res = _createMatrixfromDimensions(mo.m,mo.n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(f(mo.mat[i][j]));
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.combine(f,mo1,mo2): returns a Matrix object obtained by applying the function f
//   to each element of the Matrix object mo1 and the corresponding element of the Matrix
//   element mo2 (which must be of the same dimension).  f must be a function of two
//   arguments.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.combine = function (f,mo1,mo2)
{ _chkMatrix('combine',1,mo1);
  _chkMatrix('combine',2,mo2);
  if (mo1.m != mo2.m || mo1.n != mo2.n)
  { throw '***ERROR: in Matrix.combine: matrix dimensions don\'t match.';
  }
  var res = _createMatrixfromDimensions(mo1.m,mo1.n);
  with (res)
    for (var i = 0; i < m; i++)
      for (var j = 0; j < n; j++)
        mat[i][j] = _chkNum(f(mo1.mat[i][j],mo2.mat[i][j]));
  return res;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.trace(mo): returns the trace of the Matrix object mo.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.trace = function (mo)
{ _chkMatrix('trace',1,mo);
  var t = 0;
  with (mo)
    for (var i = 0; i < Math.min(m,n); i++)
      t += mat[i][i];
  return _chkNum(t);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.det(mo): returns the determinant of the Matrix object mo, which be square.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.det = function (mo)
{ _chkMatrix('det',1,mo);
  if (mo.m != mo.n)
  { throw '***ERROR: in Matrix.det: argument is not square.';
  }
  with (LUDecomposition)
    return _chkNum(det(create(mo)));
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.inverse(mo): returns the inverse of the Matrix object mo.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.inverse = function (mo)
{ _chkMatrix('inverse',1,mo);
  return Matrix.solve(mo,Matrix.identity(mo.m,mo.m));
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.solve(A,B): solves the matrix equation A*X = B, returning x as a Matrix object.
//   If A is square, the solution is exact; if A has more rows than columns, the solution
//   is least squares. (No solution is possible if A has fewer rows than columns.)
//   Uses LUDecomposition.js and QRDecomposition.js.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.solve = function (A,B)
{ _chkMatrix('solve',1,A);
  _chkMatrix('solve',2,B);
  if (A.m == A.n) with (LUDecomposition) return solve(create(A),B);
  else if (A.m > A.n)
    with (QRDecomposition)
    { var temp = create(A);
      return solve(temp,B);
    }
  else throw '***ERROR: in Matrix.solve: argument 1 has fewer rows than columns.';
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.eigenstructure(mo): given a square Matrix object mo, returns an object whose
//    fields contain the eigenvectors and eigenvalues. The fields are as follows:
//    V    the columnwise eigenvectors as a Matrix object
//    lr   the real parts of the eigenvalues as an array
//    li   the imaginary parts of the eigenvalues as an array
//    L    the block diagonal eigenvalue matrix as a Matrix object
//    isSymmetric   whether the matrix is symmetric or not (boolean).
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.eigenstructure = function (mo)
{ _chkMatrix('eigenstructure',1,mo);
  if (mo.m != mo.n)
  { throw '***ERROR: in Matrix.eigenstructure: argument is not a square matrix.';
  }
  return EVDecomposition.create(mo);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Matrix.display(mo,dp): displays the Matrix object mo using dp decimal places. If dp is
//  omitted, the default in IOUtils.js is used.
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
this.display = function (mo,dp)
{ _chkMatrix('display',1,mo);
  if (dp == null) dp = 3;
  displayMat(mo.mat,null,null,dp);
}

} // end of createMatrixPackage