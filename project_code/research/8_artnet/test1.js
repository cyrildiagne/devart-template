// var artnetclient = require('artnet-node').Client;
// var client = artnetclient.createClient('192.168.0.2', 6454);
// var i = 0;
// var speed = 0.05;
// setInterval(function(){
//   i += Math.PI / 2 * speed;
//   var val = Math.floor( (1 + Math.sin(i)) * 127 );
//   client.send([val]);
// }, 1000/30);



var address = "192.168.0.2";
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