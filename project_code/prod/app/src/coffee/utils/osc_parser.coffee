# derived from deanm/omgosc
class OSCParser

  constructor : (@callback) ->
    @array_buffer = new ArrayBuffer 4
    @data_view = new DataView @array_buffer

  getUTF8String : (view, offset, length) ->
    utf16 = new ArrayBuffer length*2
    utf16View = new Uint16Array utf16
    for i in [0...length]
      utf16View[i] = view.getUint8 offset+i
    return String.fromCharCode.apply(null, utf16View)

  readString : (buffer, start) ->
    end = start
    len = buffer.byteLength
    end++ while (end < len && buffer.getUint8(end) != 0)
    return @getUTF8String(buffer, start, end-start)

  readBlob : (buffer, start) ->
    len = @readInt(buffer, start)
    start += 4
    return buffer.slice(start, start+len)

  readFloat : (buffer, pos) ->
    @data_view.setUint8(0, buffer.getUint8(pos)   )
    @data_view.setUint8(1, buffer.getUint8(pos+1) )
    @data_view.setUint8(2, buffer.getUint8(pos+2) )
    @data_view.setUint8(3, buffer.getUint8(pos+3) )
    return @data_view.getFloat32(0, false)

  readInt : (buffer, pos) ->
    @data_view.setUint8(0, buffer.getUint8(pos)   )
    @data_view.setUint8(1, buffer.getUint8(pos+1) )
    @data_view.setUint8(2, buffer.getUint8(pos+2) )
    @data_view.setUint8(3, buffer.getUint8(pos+3) )
    return @data_view.getInt32(0, false)

  parse : (msg, pos, callback_) ->

    if(callback_) then @callback = callback_

    view = new DataView(msg)

    path = @readString(view, pos)
    pos += path.length + 4 - (path.length & 3)

    if path is '#bundle'
      pos += 8  # Skip timetag, treat everything as 'immediately'
      while (pos < view.byteLength)
        len = @readInt(view, pos)
        pos += 4
        @parse(msg, pos)
        pos += len
      return

    typetag = @readString(view, pos)
    pos += typetag.length + 4 - (typetag.length & 3)

    params = [ ]

    il = typetag.length
    for i in [1...il]
    #for (i = 1, il = typetag.length i < il ++i) 
      tag = typetag[i]
      switch (tag)
        when 'T'
          params.push true
          break
        when 'F'
          params.push false
          break
        when 'N'
          params.push null
          break
        when 'I'
          params.push undefined
          break
        when 'f'
          params.push @readFloat(view, pos)
          pos += 4
          break
        when 'i'
          params.push @readInt(view, pos)
          pos += 4
          break
        when 's'
          str = @readString(view, pos)
          pos += str.length + 4 - (str.length & 3)
          params.push(str)
          break
        when 'b'
          bytes = @readBlob(view, pos)
          pos += 4 + bytes.byteLength + ((4 - (bytes.byteLength & 3)) & 3)
          params.push(bytes)
          break
        else
          console.log('WARNING: Unhandled OSC type tag: ' + tag)
          break
    
    if(@callback) 
      e = 
        path    : path
        typetag : typetag.substr(1)
        params  : params
      @callback(e)