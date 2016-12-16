var rootId=require('/etc/main_server/conf.json').gitlab.username;
var password=require('/etc/main_server/conf.json').gitlab.password;
var gitlab = require('./gitlab.js')('localhost',rootId,password);
var async = require('async');
 var main_server = 
{
	hostname: 'localhost' ,//require('../config/conf.json').host.hostname,
	port: '9000'     //require('../config/conf.json').host_port.port
}

var fs = require('fs');
var path = require('path')
var userList = fs.readFileSync(path.join(__dirname + '/..' + '/userList')).toString('utf-8').split('\n');
userList.pop()
console.log(userList)
languages = ['cpp','cpp14','java','python2','python3'];

//start_time and end_time are JavaScript Date objects

function revaluation(lab,start_time,end_time,admin_key,callback)
{

	var max_scores = {};
	var number_of_requests=0;
	var socket =  require('socket.io-client')('https://'+main_server.hostname+":"+main_server.port);
	socket.on('error',function(err)
	{
		console.log(err)
	})
	//Get all the commits from the userList for the specified lab 
	gitlab.getPrivateToken(function(err,token) 			//Get the private token required to get all the commits
	{
		console.log(token)
		for(var i=0;i<userList.length;i++)
		{
			user = userList[i];					
			gitlab.getProjectId(token,user,lab,function(error,id)
			{
				
				gitlab.getCommits(token,id,function(err,commits) 
				{
					commits.filter(function(commit)  			//Check if the commit is within the lab timings
					{
						var commit_date = new Date(commit["created_at"]);
						if(commit_date >= start_time && commit_date <= end_time) return true;
						else return false;

					})

					for(var commit in commits) 
						for(var lang in languages) 
						{
							socket.emit('submission',[user,lab,commits[commit].id,languages[lang],admin_key]);
							number_of_requests++;
						}


					socket.on('scores',function(data)
					{
						var total_score =0;
						for(var i =0; i < data.marks.length;i++) total_score+=Number(data.marks[i]);
						if(max_scores[data.id_no]) max_scores[data.id_no] = Math.max(max_scores[data.id_no],total_score);
						else max_scores[data.id_no]=total_score;

						number_of_requests--;
						if(!number_of_requests)
						{

							 return callback(null,
							 	{
							 		labName:lab,
							 		score:max_scores
							 	});
						}


					})

					
				})
			})
		}
	})
}


module.exports = function(labs,callback)
{
	var lab_tasks = labs.map(function(lab_info)
	{
		return function(call)
		{
			return revaluation(lab_info.lab,lab_info.startDate, lab_info.endDate,lab_info.admin_key,call);
		}
	});

	async.parallel(lab_tasks,callback);
}
