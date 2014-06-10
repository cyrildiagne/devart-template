XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
jws = require 'jws'

class GAPI

  key : "-----BEGIN RSA PRIVATE KEY-----\n
MIICXQIBAAKBgQCjNzoRnP3hnzWDWV42HFnFNWDSKAW8uxHzF1XQi2IJipxaTaxR\n
SWLILuKKPpy3drknNwMjaGbX/KdkvqtrdqAm8blzgEhfGpI8e7sTmYc9YbB0xUjU\n
+NbQVfmX8f21ERS15669+vUoHTGam7RMO0O9nU/Zi3n6M9Q1NNwbu+rZwwIDAQAB\n
AoGAFcEDpVtWX18YA9TCgNXQhT9zEy+wbBJG9y6SCoS5YWovIr4djIwKdYICQcjM\n
nItfbEGh0nNU2c7cBMqBEIa0G6Y1MfNAnPKrT1ALzfTD80mBa6m7iDfzuj8LhmK/\n
9gXUHH5DJSvI+63fd2T5OarOZKNrwSCXqmZ6sGHeZeJ1GxECQQDRLXdz00qPwe3A\n
2KzdbL91gH7QfGrwvxSB4jmtxAbG1cCPq1WiDs1z9W+xmeDiE/9jXyNe50qd+vqX\n
U8j9kyn7AkEAx8AAI3n3/RNdBYbf0PGbRnZwqWoH3fNE/mN3hXuSCzsrFST7LebA\n
NyMaG8LUgJporvuCjbuoZpo43rBzxvWM2QJBAJOQaJlsMEhz/Z6y/FgEdJiW+l9n\n
tiV6FyR9jEUaadFxT7PKodF+cc/hEFeQ/4VdqCfZIOG9dvU17fw9XigM3msCQBK4\n
Xcr1XVZsgCVKdKNiYUkDRJ+7/izA5dBphgQOhqtiyjDbHGc63vzL32CGq9+5mOH9\n
VEjwM2IaRgYox1D4JlECQQCo4Xzewiz7sEfhipvqGxY7o4w5OVD3Eh0nJIYFkJk5\n
m5Z8t1NKD/qH73lqXt4Rvs763w4poFxaKdvE5YEg4hJo\n
-----END RSA PRIVATE KEY-----"
  iss: '367783635550-j53tjvr7sg0p3gs4o9d3fkffi2bssjtb@developer.gserviceaccount.com'
  scope: 'https://www.googleapis.com/auth/devstorage.read_write'

  constructor : (options, callback) ->
    @token = null
    @token_expires = null

  getToken : (callback) ->
    if (@token && @token_expires && (new Date()).getTime() < @token_expires * 1000)
      callback(null, @token)
    else
      @getAccessToken(callback)

  getAccessToken : (callback) ->
    iat = Math.floor(new Date().getTime() / 1000)

    payload =
      iss: GAPI::iss
      scope: GAPI::scope
      aud: 'https://accounts.google.com/o/oauth2/token'
      exp: iat + 3600
      iat: iat

    signedJWT = jws.sign
      header: {alg: 'RS256', typ: 'JWT'}
      payload: payload
      secret: GAPI::key

    url = 'https://accounts.google.com/o/oauth2/token'
    params = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + signedJWT
    req = new XMLHttpRequest()
    req.open "POST", url, true
    req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
    req.onload = (e) =>
      if req.status is 200
        d = JSON.parse(req.responseText)
        if d.error
          @token = null
          @token_expires = null
          callback(d, null)
        else
          console.log 'got new token'
          @token = d.access_token
          @token_expires = iat + 3600
          callback null, @token
    req.send params


gapi = new GAPI()
http = require 'http'
http.createServer( (req, res) ->
  res.writeHead 200, 
    'Content-Type': 'text/plain'
    'Access-Control-Allow-Origin' : '*'
  gapi.getToken (err, token) -> res.end token
).listen 8000

console.log 'listening on 8000'