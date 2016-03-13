var express = require('express');
var app = express();
var server = require('http').createServer(app);
var sys = require('sys')
var exec = require('child_process').exec;
var bodyParser = require('body-parser');
var fs = require('fs');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/requestRun', function(req, res){
  var submission_id = req.body.id;
  var exec_command = 'sh extract_run.sh ';
  exec_command = exec_command.concat(submission_id);
  exec(exec_command,function (error, stdout, stderr) {
    var array = fs.readFileSync('submissions/'+submission_id+'/scores.txt').toString().split("\n");
    exec('sh cleanup.sh '.concat(submission_id));
    // var array = stdout.split('\n');
    array.pop(); //remove last space
    console.log(array);
    // res.send(true);
    res.send(array);
    //TODO: post json of marks
  });
});

server.listen(8080);
console.log("Listening at 8080");
