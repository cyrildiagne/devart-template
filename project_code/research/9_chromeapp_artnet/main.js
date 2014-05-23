// var address = "192.168.0.2";
var address = "127.0.0.1";
var port = 3007;

var val = 0;
var data = new Int8Array([ 65, 114, 116, 45, 78, 101, 116, 0, 0, 80, 0, 14, 0, 0, 0, 0, 0, 1, val ]);

var udp = chrome.sockets.udp;

udp.create({}, function (socketInfo) {
  var socketId = socketInfo.socketId;
  // chrome.socket.connect( socketId, address, port, function (result) {
    // console.log("connected with id " + socketId);
  console.log("created " + socketId);
  udp.bind( socketId, "0.0.0.0", 0, function (result) {

    if(result < 0) {
      console.log(chrome.runtime.lastError.message);
    } else {
      udp.send( socketId, data.buffer, address, port, function (sendInfo) {
        console.log("done");
        if (sendInfo.resultCode < 0 || sendInfo.bytesWritten < 0) {
          console.log(chrome.runtime.lastError.message);
        }
      });
    }
  });
});