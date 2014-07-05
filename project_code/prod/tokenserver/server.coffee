XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest
jws = require 'jws'
secret = require './secret'
wol = require 'wake_on_lan'


timeout = -1
heartbeat = true


class GAPI

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
      iss: secret.iss
      scope: secret.scope
      aud: 'https://accounts.google.com/o/oauth2/token'
      exp: iat + 3600
      iat: iat

    signedJWT = jws.sign
      header: {alg: 'RS256', typ: 'JWT'}
      payload: payload
      secret: secret.key

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

gapi.getToken (err, token) -> 
  if err then throw err
  else console.log token

http = require 'http'
http.createServer( (req, res) ->
  res.writeHead 200, 
    'Content-Type': 'text/plain'
    'Access-Control-Allow-Origin' : '*'
  gapi.getToken (err, token) -> res.end token
).listen 8081

http = require 'http'
http.createServer( (req, res) ->
  res.writeHead 200, 
    'Content-Type': 'text/plain'
    'Access-Control-Allow-Origin' : '*'
  res.end secret.apiKey
).listen 8082

http = require 'http'
http.createServer( (req, res) ->
  res.writeHead 200, 
    'Content-Type': 'text/plain'
    'Access-Control-Allow-Origin' : '*'
  res.end 'heartbeat received'
  heartbeat = true
).listen 8083


console.log 'listening on 8081 (token) & 8082 (apikey)'
console.log 'api key : '+secret.apiKey


wakeWinMachine = ->
  wol.wake 'C0:3F:D5:63:1E:49'


setInterval wakeWinMachine, 60000
wakeWinMachine()


restart = ->
  sudo = require 'sudo'
  options =
    cachePassword : true
    password : secret.sudo
  child = sudo [ 'shutdown', '-r', 'now' ], options


checkHeartbeat = ->
  if heartbeat isnt true
    restart()
  heartbeat = false
  setTimeout checkHeartbeat, 60*1000

setTimeout checkHeartbeat, 5*60*1000
console.log 'listening on 8083'

