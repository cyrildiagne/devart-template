wol = require 'wake_on_lan'

wol.wake 'C0:3F:D5:63:1E:49', (error) ->
  if error
    # handle error
    console.log error
  else
    # done sending packets
    console.log 'done!'