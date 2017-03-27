var argv = require('minimist')(process.argv.slice(2));
var Table = require('cli-table');

var submit = function(id_no, current_lab, commit_hash, language) {
	var req = [id_no, current_lab , commit_hash, language];
	var socket = require('socket.io-client')('localhost'+':'+'9000');
	console.log("\nRequest array: "+req);
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
		var table = new Table({
			chars: { 'top': '═' , 'top-mid': '╤' , 'top-left': '╔' , 'top-right': '╗',
			'bottom': '═' , 'bottom-mid': '╧' , 'bottom-left': '╚' , 'bottom-right': '╝', 
			'left': '║' , 'left-mid': '╟' , 'mid': '─' , 'mid-mid': '┼',
			'right': '║' , 'right-mid': '╢' , 'middle': '│' },
			head: ['Test Case #', 'Status', 'Score'],
			colWidths: [15,25,15]
		});

		for(i=0;i<data.marks.length;i++) {
	    	total_score=total_score+ parseInt(data.marks[i]);
	    	status = 'Accepted';
	    	if(data.comment[i]===0) {
	    		status='Wrong Answer';
	    	}
	    	if(data.comment[i]==1 && data.marks[i]===0) {
	    		status='Compilation Error';
	    	}
	    	if(data.comment[i]==2 && data.marks[i]===0) {
	    		status='Timeout';
	    	}
	    	table.push(
	    		[(i+1), status, data.marks[i]]
	    		);
	    }
	    console.log(table.toString());
	    if (total_score < 0) {
	    	total_score = 0;
	    }
	    if (data.status!==0) {
	    	console.log('Penalty:' + data.penalty);
	    }
	    console.log('Total Score = ' + total_score);
	    if (data.status===0) {
	    	console.log('Warning:' + 'This lab is not active. The result of this evaluation is not added to the scoreboard.');
	    }
	    console.log(new Buffer(data.log, 'base64').toString());
	    process.exit(0);
	});
};
/*
 commandline options are:
	-l	lab name
	-i	student id number
	-h	commit hash of the student repository
	--lang	programming language
*/
if (argv.l && argv.i && argv.lang) {
	if (argv.h) {
		submit(argv.i, argv.l, argv.h, argv.lang);
	}
	else {
		submit(argv.i, argv.l, '', argv.lang);
	}
}
else {
	console.log('Please fill required arguments');
}
