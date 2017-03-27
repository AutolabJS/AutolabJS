var argv = require('minimist')(process.argv.slice(2));
var io = require('socket.io-client');

var submit = function(host, id_no, current_lab, commit_hash, language) {
	var req = [id_no, current_lab , commit_hash, language];
	var socket = io.connect(host);

	socket.emit('submission', req);
	socket.on('invalid', function(data) {
		console.log('Access Denied. Please try submitting again');
	});

	socket.on('submission_pending',function(data) {
		console.log('You have a pending submission. Please try after some time.');
	});

	socket.on('scores', function(data) {
		total_score=0;
		console.log('\nSubmission successful. Retreiving results');
		delete data.socket;
		console.log("\nResults object: %j", data);
	});
};
/*
 commandline options are:
	-l	lab name
	-i	student id number
	-h	commit hash of the student repository
	--lang	programming language
	--host	server url, ex: localhost:9000
*/
if (argv.host && argv.l && argv.i && argv.lang) {
	if (argv.h) {
		submit(argv.host, argv.i, argv.l, argv.h, argv.lang);
	}
	else {
		submit(argv.host, argv.i, argv.l, '', argv.lang);
	}
}
else {
	console.log('Please fill required arguments');
}
