var socket = require('./socket.io/node_modules/socket.io-client')('https://localhost:9000');
for(var i=100;i<=999;i++)
{
  var x="2015A7PS";
  x=x+i+'G';
  socket.emit('submission', [x, 'lab2', '']);

}
socket.on('scores', function(data) {
  console.log(data);
});
