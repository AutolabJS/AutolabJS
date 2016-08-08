var main_server = require('../../load_balancer/nodes_data_conf.json').server_info
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
	for(score in data.marks) total_score+=Number(score);
	if(max_scores[data.id]) max_scores[data.id] = Math.max(max_scores[data.id],total_score);
	else max_scores[data.id]=total_score;
	number_of_requests--;
	if(!number_of_requests)
	{
		fd = fs.openSync('./reval_score.csv', 'w')
		for( id in max_scores)
		{
			fs.write(fd,id + "," + max_scores[id] + '\n');
		}
		fs.closeSync(fd);
	}
})

process.exit();

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
