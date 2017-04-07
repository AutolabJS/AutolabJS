
const argv = require('minimist')(process.argv.slice(2));
const io = require('socket.io-client');

const submit = function submit(host, idNo, currentLab, commitHash, language) {
  const req = [idNo, currentLab, commitHash, language];
  const socket = io.connect(host);

  socket.emit('submission', req);
  socket.on('invalid', () => {
    console.log('Access Denied. Please try submitting again');
    socket.disconnect();
  });

  socket.on('submission_pending', () => {
    console.log('You have a pending submission. Please try after some time.');
    socket.disconnect();
  });

  socket.on('scores', (data) => {
    const score = data;
    console.log('Submission successful. Retreiving results');
    delete score.socket;
    delete score.time;
    delete score.status;
    delete score.penalty;
    console.log('Results object: %j', score);
    socket.disconnect();
  });
};
/*
 commandline options are:
  -l     lab name
  -i     student id number
  -h     commit hash of the student repository
  --lang programming language
  --host server url, ex: localhost:9000
*/
if (argv.host && argv.l && argv.i && argv.lang) {
  if (argv.h) {
    submit(argv.host, argv.i, argv.l, argv.h, argv.lang);
  } else {
    submit(argv.host, argv.i, argv.l, '', argv.lang);
  }
} else {
  console.log('Please fill required arguments');
}
