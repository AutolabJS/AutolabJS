var io = require('socket.io');
var APIKeys = require('/etc/main_server/APIKeys.json').keys
var exec = require('child_process').exec
var fs = require('fs');
module.exports = function(socket)
{


	if(socket.handshake.session.key)
		{
			var labs = require('/etc/main_server/labs.json').Labs
			var lab_names =[]
			labs.map(function(lab)
			{
				lab_names.push(lab["Lab_No"]);
			})
			socket.emit('login_success',{})
			socket.emit("reval",{Labs:lab_names})
		}

	socket.on('authorize',function(data)
	{

		if(APIKeys.indexOf(data.key) != -1 )
		{


			socket.handshake.session.key = data.key;
			socket.emit("successful login");

		}
		else socket.emit("login failed");



	})


	socket.on('send_reval_data',function(data)
	{


		if(socket.handshake.session.key)
			{
				socket.emit('login_success',{})

				var labs = require('/etc/main_server/labs.json').Labs
				var lab_names =[]
				labs.map(function(lab)
				{
					lab_names.push(lab["Lab_No"]);
				})
				socket.emit('login_success',{})
				socket.emit("reval",{Labs:lab_names})

			}
	})

	socket.on('revaluate',function(data)
	{
		if(!socket.handshake.session.key) return;
		var labs = require('/etc/main_server/labs.json').Labs;

		var i =0;
		while( i < labs.length && labs[i]["Lab_No"]!=data.labname)i++;
		if(i> labs.length) return;



		var start_date = labs[i].start_date + '/'+labs[i].start_month+'/'+labs[i].start_year + ' ' + labs[i].start_hour + ':' + labs[i].start_minute + ':00';
		var end_date =  labs[i].end_date + '/'+ labs[i].end_month+'/'+labs[i].end_year + ' ' + labs[i].end_hour + ':' + labs[i].end_minute + ':00';

		exec('cd reval; bash reval.sh '+data.labname+' "'+start_date+'" "'+end_date+'" localhost ' ,function(error,stdout,stderr)
		{
			checkLab(data.labname);

		})

	})



	socket.on('logout',function(data)
	{
		delete socket.handshake.session.key
		socket.emit('logged out');
	})



	// Continuously check the reval directory to check if the end file exists for 30 seconds, after which a link
	// to download the file can be sent to the admin on the portal.
	function checkLab(lab)
	{
		var time =0;
		var handle = setInterval(function()
		{


			fs.stat('./reval/'+lab+"_reval_score.csv",function(err,stat)
			{
				if(err)
				{
					console.log(err)
					time++;
					if(time > 30)
					{
						clearInterval(handle);
						socket.emit('update_score_timeout',lab);
					}
				}
				else
				{
					socket.emit('update_score',lab);
					clearInterval(handle);
				}
			})

		},1000);
	}

}
