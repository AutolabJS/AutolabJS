var io = require('socket.io');
var APIKeys = require('/etc/main_server/APIKeys.json').keys
var config = require('/etc/main_server/conf.json');
var exec = require('child_process').exec
var path = require('path')
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
		console.log(socket.handshake.session.key)
		var lab_revaluation = [];
		var labs = require('/etc/main_server/labs.json').Labs;

		console.log(data)
		for(var rev in data)
		{
			var i =0;
			while( i < labs.length && labs[i]["Lab_No"]!=rev.labname)i++;
			if(i> labs.length) continue;
			var start_date = data[rev].start_date + '/'+data[rev].start_month+'/'+data[rev].start_year + ' ' + data[rev].start_hour + ':' + data[rev].start_minute + ':00';
		var end_date =  data[rev].end_date + '/'+ data[rev].end_month+'/'+data[rev].end_year + ' ' + data[rev].end_hour + ':' + data[rev].end_minute + ':00';
			lab_revaluation.push({
				lab:data[rev].labname,
				startDate: new Date(start_date),
				endDate: new Date(end_date),
				admin_key : socket.handshake.session.key
			})
		}
		


		
		console.log(lab_revaluation)

		require('./reval/reval.js')(lab_revaluation,function(err,newScores)
		{
			console.log(newScores)
			for(var i in newScores)
			{
				 var write_to_file = fs.createWriteStream(path.join(__dirname,'/reval/',newScores[i]['labName']+'_reval_score.csv'),{flags:'w'});

				 write_to_file.on('open',function(file)
				 {
				 	var score_string ="";
				 	for(var id in newScores[i]['score'])
				 	{
				 		score_string = score_string + id + ',' + newScores[i]['score'][id] + '\n';
				 	}

				 	write_to_file.write(score_string,function()
				 	{
				 		socket.emit('update_score',newScores[i]['labName'])
				 	})
				 })

				 write_to_file.on('error',function(err)
				 {
				 	console.log(error);
				 })

			}
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
