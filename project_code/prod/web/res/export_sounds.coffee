fs = require 'fs'
which = require 'which'
path = require 'path'
{spawn, exec} = require 'child_process'

in_path = 'sounds'
out_path = path.join '..', 'bin', 'assets', 'sounds'

convert = (input, output) ->
  cmd = which.sync 'lame'
  options = ['-V2', input, output]
  prcss = exec "#{cmd} -V2 #{input} #{output}", (err, stdout, stderr) ->
    if err 
      console.log err
    console.log stderr

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

s_path = path.join 'birds', 'track'

files = fs.readdirSync path.join(in_path,s_path)
for f in files
  if f[0] is '.' then continue
  s = f.split('.')[0]
  mkdirRecSync path.join(out_path,s_path)
  input  = path.join in_path,  s_path, s+'.wav'
  output = path.join out_path, s_path, s+'.mp3'
  convert input, output
