var address = "127.0.0.1";
var port = 6454;

var val = 255;
var data = new Buffer([ 65, 114, 116, 45, 78, 101, 116, 0, 0, 80, 0, 14, 0, 0, 0, 0, 0, 1, val ]);

var socket = require('dgram').createSocket("udp4");
socket.send(data, 0, data.length, port, address, function(err, bytes) {
  if(err) {
    console.log(err);
  } else {
    console.log(bytes);
  }
});