var io = require('socket.io');
var APIKeys = require('./config/APIKeys.json').keys
var exec = require('child_process').exec

module.exports = function(socket)
{
	if(socket.handshake.session.key) 
		{
			socket.emit('login_success',{})	
			socket.emit("reval",{Labs:["lab2","lab3","lab4","lab5","lab6","lab7"]})
		}
	
	socket.on('authorize',function(data)
	{
		if(APIKeys.indexOf(data.key) != -1 )
		{
			console.log(APIKeys)
			console.log(APIKeys.indexOf(data.key))
			socket.handshake.session.key = data.key;

		}
		console.log(data)
		
		// console.log(socket.handshake.session)
	})

	
	socket.on('send_reval_data',function(data)
	{
		console.log(socket.handshake.session)	
		if(socket.handshake.session.key)socket.emit('login_success',{})
		if(socket.handshake.session.key) socket.emit("reval",{Labs:["lab2","lab3","lab4","lab5","lab6","lab7"]})
	}) 

	socket.on('revaluate',function(data)
	{
		if(!socket.handshake.session.key) return;
		exec('cd reval; bash reval.sh lab2 "02/02/1970 08:08:08" "02/02/2018 08:08:08" localhost ' ,function(error,stdout,stderr)
		{
			sys.puts(stdout)
			sys.puts(stderr)
		})
		console.log(data)
	})



	socket.on('logout',function(data)
	{
		delete socket.handshake.session.key
	})



	
	
}