# class GAPI

#   key : ''
#   iss: ''
#   scope: 'https://www.googleapis.com/auth/devstorage.read_write'

#   constructor : (options, callback) ->
#     @token = null
#     @token_expires = null

#   getToken : (callback) ->
#     if (@token && @token_expires && (new Date()).getTime() < @token_expires * 1000)
#       callback(null, @token)
#     else
#       @getAccessToken(callback)

#   getAccessToken : (callback) ->
#     iat = Math.floor(new Date().getTime() / 1000)

#     payload =
#       iss: GAPI::iss
#       scope: GAPI::scope
#       aud: 'https://accounts.google.com/o/oauth2/token'
#       exp: iat + 3600
#       iat: iat

#     token = new jwt.WebToken(JSON.stringify(payload), JSON.stringify({typ:'JWT', alg:'HS256'}))
#     signedJWT = token.serialize GAPI::key

#     console.log signedJWT

#     url = 'https://accounts.google.com/o/oauth2/token'
#     params = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + signedJWT
#     req = new XMLHttpRequest()
#     req.open "POST", url, true
#     req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
#     req.onreadystatechange = () =>
#       console.log req.readyState
#     req.onload = (e) =>
#       if req.status is 200
#         d = JSON.parse(req.responseText)
#         if d.error
#           @token = null
#           @token_expires = null
#           callback(d, null)
#         else
#           @token = d.access_token
#           @token_expires = iat + 3600
#           callback null, @token
#     req.send params

class GAPI

  getToken : (callback) -> 

    # accounts.google.com doesn't accept cors so we need to do that externally
    req = new XMLHttpRequest()
    req.open 'GET', 'http://localhost:8081', true
    req.onload = (e) =>
      if req.status is 200
        callback null, req.responseText
      else callback req
    req.send()

  getApiKey : (callback) ->
    req = new XMLHttpRequest()
    req.open 'GET', 'http://localhost:8082', true
    req.onload = (e) =>
      if req.status is 200
        callback null, req.responseText
      else callback req
    req.send()


class CloudStorage

  bucket : 'mr-kalia-replays'

  constructor : () ->
    @gapi = new GAPI()

  upload : (filename, data, callback) ->
    
    numFrames = data.size / (4*3*15)
    duration = numFrames * 1/50
    if duration < 30
      console.log 'performance too short (< 30s), not uploading...'
      return

    @gapi.getToken (err, token) => 
      if (err)
        return callback(err)

      headers =
        'Content-Type' : 'binary/octet-stream'
        'Authorization' : 'Bearer ' + token
        'x-goog-acl' : 'public-read'
        'x-goog-api-version' : 2

      url = 'http://'+ CloudStorage::bucket + '.storage.googleapis.com/' + filename

      req = new XMLHttpRequest()
      req.open "PUT", url, true
      req.setRequestHeader(k,v) for k, v of headers
      req.onload = (e)=>
        if req.status is 200
          @notifyIndexRepo filename, (res) ->
            if callback then callback res
      req.send data

  notifyIndexRepo : (filename, callback) ->

    @gapi.getApiKey (err, apiKey) ->
      if err
        return callback(err)
      data =
        key : apiKey
        tag : filename
      # $.post 'http://localhost:8080/last', data, callback
      $.post 'http://devartmrkalia.com/last', data, callback
