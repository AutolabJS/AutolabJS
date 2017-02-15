var fs = require('fs');
var express = require('express');
var app = express();
var https_config={
  key : fs.readFileSync('./ssl/key.pem'),
  cert: fs.readFileSync('./ssl/cert.pem'),
  rejectUnauthorized:false,
};
var https = require('https');
var server = https.createServer(https_config,app);
var sys = require('sys');
var http = require('http');
var exec = require('child_process').exec;
var bodyParser = require('body-parser');
var fs = require('fs');
var path = require('path');
var conf,scores;
if(process.env.mode === 'TESTING')
{
  conf = require('../deploy/configs/execution_nodes/conf.json');
  scores = require('../deploy/configs/execution_nodes/scores.json');
}
else
{
  conf = require('/etc/execution_node/conf.json');
  scores = require('/etc/execution_node/scores.json');
}


app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));

app.use(bodyParser.json());
app.get('/connectionCheck', function (req,res) {
  console.log('connectionCheck requested');
  res.send(true);
});

app.post('/requestRun', function(req, res){
  console.log('requestRun post request recieved');
  res.send(true);
  console.log(req.body);
  var submission_id = req.body.id_no;
  var lab = req.body.Lab_No;
  var commit = req.body.commit;
  var language = req.body.language;
  var exec_command = 'bash extract_run.sh ';
  exec_command = exec_command.concat(submission_id+" "+lab+" "+gitlab_hostname+" \""+commit + "\" " + language);
  process.env.LANGUAGE = language;
  console.log(exec_command)
  exec(exec_command,function (error, stdout, stderr) {
    
    var array = fs.readFileSync(path.join(__dirname + '/submissions/'+submission_id+'/'+lab+'/results/scores.txt')).toString().split("\n");
    var comment = fs.readFileSync(path.join(__dirname + '/submissions/'+submission_id+'/'+lab+'/results/comment.txt')).toString().split("\n");
    var log = fs.readFileSync(path.join(__dirname + '/submissions/'+submission_id+'/'+lab+'/results/log.txt')).toString();
    if(!log.length)
    {
        log = "NO LOGS FOR THIS EVALUATION";
    }
    var log_b64 = new Buffer(log).toString('base64');
    exec('bash cleanup.sh '.concat(submission_id+" "+lab));
    array.pop(); //remove last space
    comment.pop();
    var body=scores;
    body.submission_details.id_no=submission_id;
    body.submission_details.commit=commit;
    body.submission_details.marks=array;
    body.submission_details.comment=comment;
    body.submission_details.Lab_No=req.body.Lab_No;
    body.submission_details.time=req.body.time;
    body.submission_details.status=req.body.status;
    body.submission_details.penalty=req.body.penalty;
    body.submission_details.socket=req.body.socket;
    body.submission_details.log=log_b64;
    body=JSON.stringify(body);

    var https_request_options ={
      hostname: load_balancer_hostname,
      port: load_balancer_port,
      path: "/sendScores",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };

    var request = https.request(https_request_options,function(res)
    {
      res.on('data',function(chunk)
      {
        //Do nothing
      });
    });

    request.on('error',function(err)
  {
    console.log(err);
  });
  request.end(body);

  });
});


load_balancer_hostname=conf.load_balancer.hostname;
load_balancer_port=conf.load_balancer.port;

gitlab_hostname=conf.gitlab.hostname;
gitlab_port=conf.gitlab.port;

var body=JSON.stringify(scores.node_details);
var https_addnode_options ={
  hostname: load_balancer_hostname,
  port: load_balancer_port,
  path: "/addNode",
  method: "POST",
  headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(body)
  },
  key : fs.readFileSync('./ssl/key.pem'),
  cert: fs.readFileSync('./ssl/cert.pem'),
  rejectUnauthorized:false,
};

var request = https.request(https_addnode_options,function(res)
{
  res.on('data',function(chunk)
  {
    //Do nothing
  });
});

request.on('error',function(err)
{
  console.log(err);
});
request.end(body);


server.listen(conf.host_port.port);
console.log("Listening at "+conf.host_port.port);
