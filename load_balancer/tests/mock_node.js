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
var conf,scores;


conf = { "load_balancer" :{
  "hostname": "localhost",
  "port": "8081"
},
"gitlab" :{
  "hostname": "localhost",
  "port": "80"
},
"host_port" :
{
  "port" : "8082"
}
}

scores = {
  "node_details":
    {
      "hostname": "localhost",
      "port": "8082"
    },
  "submission_details":
    {
      "marks" :[],
      "comment" :[],
      "id_no" :"",
      "Lab_No": "",
      "commit": "",
      "time":"",
      "status": "",
      "penalty": "" ,
      "socket": ""
    }
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

    var body={};
    body.submission_details={};
    body.submission_details.id_no='';
    body.submission_details.commit='';
    body.submission_details.marks='';
    body.submission_details.comment='';
    body.submission_details.Lab_No='';
    body.submission_details.time='';
    body.submission_details.status='';
    body.submission_details.penalty='';
    body.submission_details.socket=req.body.socket;
    console.log(req.body)
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
