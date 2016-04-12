var express = require('express');
var app = express();
var server = require('http').createServer(app);
var http = require('http');
var bodyParser = require('body-parser');
var fs = require('fs');
var sys = require('sys')
var exec = require('child_process').exec;
var nodes_data = require('./nodes_data_conf.json');
var mysql = require('mysql');


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
  array = submission_json.marks
  if(submission_json.status ==  1 || submission_json.status == 2)
  {
    total_score = 0;
    for(i in array)
    {
      total_score=total_score+parseInt(array[i]);
    }
    total_score = total_score - parseInt(submission_json.penalty);
    if(total_score < 0)
    {
      total_score = 0;
    }
    code_download_flag=0;
    table_name='l'+submission_json.Lab_No;
    q="SELECT * FROM "+table_name+" WHERE id_no = \'"+submission_json.id_no+"\'";
    connection.query(q ,function(err, rows, fields) {
      if(rows.length==0)
      {
        var q1='INSERT INTO '+table_name+' VALUES (\''+submission_json.id_no+'\', '+ total_score+',\''+submission_json.time+'\')';
        connection.query(q1, function(err, rows, fields) {
        });
        code_download_flag=1;
      }
      else {
        if(rows[0].score < total_score)
        {
          var q1='UPDATE '+table_name+' SET score='+total_score+', time=\''+submission_json.time+'\' WHERE id_no=\''+submission_json.id_no+'\'' ;
          connection.query(q1, function(err, rows, fields) {
          });
          code_download_flag=1;
        }
      }
      if(code_download_flag==1)
      {
        var exec_command = 'bash savecode.sh ';
        exec_command = exec_command.concat(submission_json.id_no+" "+submission_json.Lab_No+" "+gitlab_hostname);
        exec(exec_command,function (error, stdout, stderr) {
        });
      }
    });
  }
});

server_hostname=nodes_data["server_info"].hostname;
server_port=nodes_data["server_info"].port;

gitlab_hostname=nodes_data["gitlab"].hostname;
gitlab_port=nodes_data["gitlab"].port;

var connection = mysql.createConnection(
  nodes_data["database"]
);

connection.connect();

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
