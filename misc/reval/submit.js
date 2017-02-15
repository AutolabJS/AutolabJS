var main_server = 
{
	hostname: require('../config/conf.json').host.hostname,
	port: require('../config/conf.json').host_port.port
}

//console.log(main_server)
var socket = require('./socket.io/node_modules/socket.io-client')('https://'+main_server.hostname+":"+main_server.port);

var fs = require('fs');
var user_commits = fs.readFileSync('./user_commits.txt').toString('utf-8').split('\n');
var i =0;

var lab = user_commits[i++];
var students = Number(user_commits[i++]);

number_of_requests=0; 

while(students--)
{
	var id = user_commits[i++];
	var number_commits = Number(user_commits[i++]);
	while(number_commits--)
	{
		var commit = user_commits[i++];
		socket.emit('submission',[id,lab,commit]);
		number_of_requests++;
	}
}

var max_scores ={};

socket.on('scores',function(data)
{
	var total_score =0;
	for(var i =0; i < data.marks.length;i++) total_score+=Number(data.marks[i]);
	//console.log(data , number_of_requests)
	if(max_scores[data.id_no]) max_scores[data.id_no] = Math.max(max_scores[data.id_no],total_score);
	else max_scores[data.id_no]=total_score;
	
	
	if(number_of_requests)
	{
		fd = fs.openSync('./reval_score.csv', 'w')

		for( var id in max_scores)
		{
			fs.writeSync(fd,id + "," + max_scores[id] + '\n');
		}
		fs.closeSync(fd);
	}
	exit();
})

function exit()     //Call this function each time scores are recieved. Exit the process after that the last data has benn writtern to csv file.
{
	number_of_requests--;
	if(!number_of_requests) process.exit();
	else return;
}
//while(number_of_requests>0);
//process.exit();

// fd = fs.openSync('./reval_score.csv', 'a')
// fs.writeSync(fd,'ssdfd,sadfdfdf\n');
// fs.writeSync(fd,'ssdfd,sadfdfdf\n');
// fs.writeSync(fd,'ssdfd,sadfdfdf\n');
// fs.writeSync(fd,'ssdfd,sadfdfdf\n');
// fs.closeSync(fd);
// process.exit();
// for(var i=100;i<=999;i++)
// {
//   var x="2015A7PS";
//   x=x+i+'G';
//   socket.emit('submission', [x, 'lab2', '']);

// }
// socket.on('scores', function(data) {
//   console.log(data);
// });
