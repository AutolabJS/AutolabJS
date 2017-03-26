var argv = require('minimist')(process.argv.slice(2));

var submit = function(id_no, current_lab, commit_hash, language) {
	var socket = require('socket.io-client')('localhost'+':'+'9000');
	var req = [id_no, current_lab, '', 'java'];
	//var req = [id_no, current_lab, commit_hash, language];
	console.log("\nRequest object: "+req);
	socket.emit('submission', req);
	socket.on('invalid', function(data) {
		console.log('Access Denied. Please try submitting again');
		process.exit(0);
	});

	socket.on('submission_pending',function(data) {
		console.log('You have a pending submission. Please try after some time.');
		process.exit(0);
	});

	socket.on('scores', function(data) {
		total_score=0;
		console.log('\nSubmission successful. Retreiving results');
		delete data.socket;
		console.log("\nResults object: %j", data);
	    	process.exit(0);
	});
};
/*
 commandline options are:
	-l	lab name
	-i	student id number
	-h	commit hash of the student repository
	-la	programming language
*/
if (argv.l && argv.i) {
	if (argv.h) {
		submit(argv.i, argv.l, argv.h, argv.la)
	}
	else {
		submit(argv.i, argv.l, '', argv.la);
	}
}
else {
	console.log('Please fill required arguments');
}
