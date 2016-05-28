var express = require('express');
var app = express();
var server = require('http').createServer(app);
var sys = require('sys')
var http = require('http');
var exec = require('child_process').exec;
var bodyParser = require('body-parser');
var fs = require('fs');
var conf = require('./conf.json');
var scores = require('./scores.json');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));

app.use(bodyParser.json());
app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/requestRun', function(req, res){
  res.send(true);
  var submission_id = req.body.id_no;
  var lab = req.body.Lab_No;
  var commit = req.body.commit;
  var exec_command = 'bash extract_run.sh ';
  exec_command = exec_command.concat(submission_id+" "+lab+" "+gitlab_hostname+" "+commit);
  exec(exec_command,function (error, stdout, stderr) {
    var array = fs.readFileSync('submissions/'+submission_id+'/'+lab+'/scores.txt').toString().split("\n");
    var comment = fs.readFileSync('submissions/'+submission_id+'/'+lab+'/comment.txt').toString().split("\n");
    exec('bash cleanup.sh '.concat(submission_id+" "+lab));
    array.pop(); //remove last space
    comment.pop();
    var body=scores;
    body["submission_details"].id_no=submission_id;
    body["submission_details"].commit=commit;
    body["submission_details"].marks=array;
    body["submission_details"].comment=comment;
    body["submission_details"].Lab_No=req.body.Lab_No;
    body["submission_details"].time=req.body.time;
    body["submission_details"].status=req.body.status;
    body["submission_details"].penalty=req.body.penalty;
    body["submission_details"].socket=req.body.socket;
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


load_balancer_hostname=conf["load_balancer"].hostname;
load_balancer_port=conf["load_balancer"].port;

gitlab_hostname=conf["gitlab"].hostname;
gitlab_port=conf["gitlab"].port;

var body=JSON.stringify(scores["node_details"]);
var request = new http.ClientRequest({
  hostname: load_balancer_hostname,
  port: load_balancer_port,
  path: "/addNode",
  method: "POST",
  headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(body)
  }
});
request.end(body);


server.listen(conf["host_port"].port);
console.log("Listening at "+conf["host_port"].port);
