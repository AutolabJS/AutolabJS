var express = require('express');
var app = express();
var server = require('http').createServer(app);
var http = require('http');
var bodyParser = require('body-parser');
var fs = require('fs');
var nodes_data = require('./nodes_data_conf.json');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/submit', function(req, res){
  res.send(true);
  if(node_queue.length!=0) {
    var assigned_node = node_queue.pop();
    var assigned_hostname = assigned_node.hostname;
    var assigned_port = assigned_node.port;
    var body=JSON.stringify(req.body);
    var request = new http.ClientRequest({
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      }
    });
    request.end(body);
  }
  else {
    job_queue.push(req.body);
  }
});

app.post('/sendScores', function(req, res){
  var submission_json = req.body.submission_details;
  var node_json = req.body.node_details;
  node_queue.push(node_json);
  res.send(true);
  if(job_queue.length!=0)
  {
    var assigned_node = node_queue.pop();
    var assigned_hostname = assigned_node.hostname;
    var assigned_port = assigned_node.port;
    var body=JSON.stringify(job_queue.pop());
    var request = new http.ClientRequest({
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      }
    });
    request.end(body);
  }
  var body=JSON.stringify(submission_json);
  var request = new http.ClientRequest({
    hostname: server_hostname,
    port: server_port,
    path: "/results",
    method: "POST",
    headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body)
    }
  });
  request.end(body);
});

server_hostname=nodes_data["server_info"].hostname;
server_port=nodes_data["server_info"].port;

var node_queue=[];
for(var i=0;i<nodes_data["Nodes"].length;i++)
{
  for(var j=0;j<nodes_data["Nodes"][i].max_submissions;j++)
  {
    node_queue.push(nodes_data["Nodes"][i]);
  }
}

var job_queue = [];

server.listen(8081);
console.log("Listening at 8081");
