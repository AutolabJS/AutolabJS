var io = require('socket.io');
var APIKeys = ["tejas"]
var exec = require('child_process').exec
var sys = require('sys')
module.exports = function(socket)
{
	socket.on('authorize',function(data)
	{
		if(APIKeys.indexOf(data.key) != -1)socket.handshake.session.key = data.key;
		console.log(data)
		// console.log(socket.handshake.session)
	})

	socket.on('send_reval_data',function(data)
	{
		if(socket.handshake.session.key) socket.emit("reval",{Labs:["lab2"]})
	}) 

	socket.on('revaluate',function(data)
	{

		exec('cd reval; bash reval.sh lab2 "02/02/1970 08:08:08" "02/02/1970 08:08:08" localhost ' ,function(error,stdout,stderr)
		{
			sys.puts(stdout)
			sys.puts(stderr)
		})
		console.log(data)
	})
}