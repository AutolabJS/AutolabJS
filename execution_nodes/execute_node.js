var express = require('express');
var app = express();
var server = require('http').createServer(app);
var sys = require('sys')
var http = require('http');
var exec = require('child_process').exec;
var bodyParser = require('body-parser');
var fs = require('fs');
var load_balancer = require('./load_balancer_conf.json');
var scores = require('./scores.json');


app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/requestRun', function(req, res){
  res.send(true);
  var submission_id = req.body.id;
  var exec_command = 'sh extract_run.sh ';
  exec_command = exec_command.concat(submission_id);
  exec(exec_command,function (error, stdout, stderr) {
    var array = fs.readFileSync('submissions/'+submission_id+'/scores.txt').toString().split("\n");
    exec('sh cleanup.sh '.concat(submission_id));
    array.pop(); //remove last space
    console.log(array);
    var body=scores;
    body["submission_details"].id=submission_id;
    body["submission_details"].marks=array;
    body=JSON.stringify(body);
    var request = new http.ClientRequest({
      hostname: load_balancer_hostname,
      port: load_balancer_port,
      path: "/sendScores",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      }
    });
    request.end(body);
  });
});

// app.post('/results', function(req, res){
//     var submission_id = req.body.id;
//     var scores = req.body.marks;
//     console.log(submission_id+ " "+scores);
//     res.send(true);
// });
load_balancer_hostname=load_balancer.hostname;
load_balancer_port=load_balancer.port;

server.listen(8082);
console.log("Listening at 8082");
