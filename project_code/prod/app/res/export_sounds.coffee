fs = require 'fs'
which = require 'which'
path = require 'path'
{spawn, exec} = require 'child_process'

in_path = 'sounds'
out_path = path.join '..', 'assets', 'sounds'

convert = (input, output, bitrate, compress, callback) ->
  cmd = which.sync 'lame'
  prcss = exec "#{cmd} -b #{bitrate} -V#{compress} -h #{input} #{output}", (err, stdout, stderr) ->
    if err 
      throw err
    if callback then callback stderr

mkdirRecSync = (path) ->
  tree = path.split '/'
  pos = 0
  for i in [0..tree.length]
    dir = tree.slice(0, i+1).join '/'
    exists = fs.existsSync dir
    if !exists
      err = fs.mkdirSync dir
      if err
        console.log 'err'
        return

publishAll = ->
  m11s = fs.readdirSync in_path
  for m11 in m11s
    if m11[0] is '.' then continue
    subs = fs.readdirSync path.join(in_path,m11)
    for sub in subs
      if sub[0] is '.' then continue
      do (m11, sub) ->
        exportItem m11, sub, 96, 6

exportItem = (m11, subfolder, bitrate=256, compress=1) ->
  s_path = path.join m11, subfolder
  files = fs.readdirSync path.join(in_path,s_path)
  for f in files
    if f[0] is '.' then continue
    s = f.split('.')[0]
    mkdirRecSync path.join(out_path,s_path)
    input  = path.join in_path,  s_path, s+'.wav'
    output = path.join out_path, s_path, s+'.mp3'
    do (output) ->
      convert input, output, bitrate, compress, ->
        console.log 'exported ' + output

s_path = path.join 'stripes', 'track'

args = process.argv.splice(2)

if args[0] is 'publish'
  out_path = path.join '..', 'bin', 'assets', 'sounds'
  publishAll()

else

  if args.length != 2
    console.log 'usage : export_sound [m11] [(sfx|track)]'
    console.log 'or : export_sound publish'
    process.kill()

  exportItem args[0], args[1]
  
