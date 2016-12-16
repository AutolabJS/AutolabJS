var fs = require('fs');
var express = require('express');
var app = express();
var https_config={
  key : fs.readFileSync('./ssl/key.pem'),
  cert: fs.readFileSync('./ssl/cert.pem'),
  rejectUnauthorized:false,
};
var https =require('https');
var httpolyglot = require('httpolyglot');
var server = httpolyglot.createServer(https_config,app);
var http = require('http');
var bodyParser = require('body-parser');
var fs = require('fs');
var sys = require('sys');
var exec = require('child_process').exec;
var nodes_data;
if(process.env.mode ==  'TESTING')  nodes_data = require('/etc/load_balancer/nodes_data_conf.json');
else nodes_data = require('/etc/load_balancer/nodes_data_conf.json');

var mysql = require('mysql');


app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/userCheck', function (req,res) {
  console.log('userCheck requested');
  res.send(true);
});

app.get('/connectionCheck', function (req,res) {
  console.log('connectionCheck requested');
  var result = 'Load Balancer Working\n';
  var numOfNodes = nodes_data.Nodes.length;
  function checkNodeConn(node){
    var options = {
      host: node.hostname,
      port: node.port,
      path: '/connectionCheck',
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };
    //send a get request and capture the response
    var req = https.request(options, function(res){
      // Buffer the body entirely for processing as a whole.
      var bodyChunks = [];
      res.on('data', function(chunk){
        bodyChunks.push(chunk);
      }).on('end', function(){
        var body = Buffer.concat(bodyChunks);
        result = result.concat('<br/>Execution Node at '+node.hostname+':'+node.port+' working: ' + body);
        console.log("nodeing");
        //return if all requets processed
        if(--numOfNodes === 0){
          console.log("DispRes");
          dispResult();
        }
      });
    });
    req.on('error', function(e) {
      result = result.concat('<br/>Execution Node at  '+node.hostname+':'+node.port+' Error: ' + e.message);
      //return if all requets processed
      if(--numOfNodes === 0){
      console.log("DispRes");
        dispResult();
      }
    });
    req.end();
  } //checkNodeConnection ends

  function dispResult(){
    res.send(result);
  }
  //Check connection of all nodes
  for(var i=0;i<nodes_data.Nodes.length;i++)
  {
    console.log(numOfNodes);
    checkNodeConn(nodes_data.Nodes[i]);
  }
});

app.post('/submit', function(req, res){
  console.log('submit post request recieved');
      console.log(req.body)


  res.send(true);

  if(node_queue.length!==0) {
     console.log(node_queue.length + ' ' + job_queue.length)
    var assigned_node = node_queue.pop();
    var assigned_hostname = assigned_node.hostname;
    var assigned_port = assigned_node.port;
    var body=JSON.stringify(req.body);
    var https_job_options={
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };

    var request = https.request(https_job_options,function(response)
    {
        response.on('data',function(chunk)
        {

        });
    });

    request.on('error',function(error)
    {
      console.log(error);
    });

    request.end(body);
  }
  else {
    job_queue.push(req.body);
  }
});

app.post('/sendScores', function(req, res){
  console.log('sendScores post request recieved');
  var submission_json = req.body.submission_details;

  var node_json = req.body.node_details;

  node_queue.push(node_json);
  res.send(true);
  if(job_queue.length!==0)
  {

    var assigned_node = node_queue.pop();
    var assigned_hostname = assigned_node.hostname;
    var assigned_port = assigned_node.port;
    var body=JSON.stringify(job_queue.pop());
    var https_job_options={
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };

    var request = https.request(https_job_options,function(response)
    {
        response.on('data',function(chunk)
        {

        });
    });

    request.on('error',function(error)
    {
      console.log(error);
    });

    request.end(body);

  }
  var body=JSON.stringify(submission_json);

  var https_job_options={
    hostname: server_hostname,
    port: server_port,
    path: "/results",
    method: "POST",
    headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body)
    },
    key : fs.readFileSync('./ssl/key.pem'),
    cert: fs.readFileSync('./ssl/cert.pem'),
    rejectUnauthorized:false,
  };

  var request = https.request(https_job_options,function(response)
  {
      response.on('data',function(chunk)
      {

      });
  });

  request.on('error',function(error)
  {
    console.log(error);
  });

  request.end(body);

  array = submission_json.marks;
  if(submission_json.status ==  1 || submission_json.status == 2)
  {
    total_score = 0;
    for(var i in array)
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
      if(process.env.mode == 'TESTING') return;
      if(rows.length===0)
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
        exec_command = exec_command.concat(submission_json.id_no+" "+submission_json.Lab_No+" "+gitlab_hostname+" "+submission_json.commit);
        exec(exec_command,function (error, stdout, stderr) {
        });
      }
    });
  }
});

app.post('/addNode', function(req, res){
  console.log('addNode post request recieved');
  res.send(true);
  // Check if the Execution node is already accounted for in the queue,return if it is.
  for(var node in node_queue) if(node_queue[node].hostname === req.body.hostname && node_queue[node].port === req.body.port) return;
  console.log(req.body)
  node_queue.push(req.body);
  console.log("Added "+req.body.hostname+":"+req.body.port+" to queue");
  
  if(job_queue.length!==0)
  {
    var assigned_node = node_queue.pop();
    var assigned_hostname = assigned_node.hostname;
    var assigned_port = assigned_node.port;
    var body=JSON.stringify(job_queue.pop());
    var https_job_options={
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };

    var request = https.request(https_job_options,function(response)
    {
        response.on('data',function(chunk)
        {

        });
    });

    request.on('error',function(error)
    {
      console.log(error);
    });

    request.end(body);

  }
});


server_hostname=nodes_data.server_info.hostname;
server_port=nodes_data.server_info.port;

gitlab_hostname=nodes_data.gitlab.hostname;
gitlab_port=nodes_data.gitlab.port;

var connection;



try {
  var connection = mysql.createConnection(
    nodes_data.database
  );
  connection.connect();

} catch (e) {
    console.log(e);

} finally {

}
var node_queue=[];
for(var i=0;i<nodes_data.Nodes.length;i++)
{
  checkNodeConn(nodes_data.Nodes[i]);
  function checkNodeConn(node) {

    var https_checkConn ={
      hostname : node.hostname,
      port : node.port,
      path : '/connectionCheck',
      key : fs.readFileSync('./ssl/key.pem'),
      cert: fs.readFileSync('./ssl/cert.pem'),
      rejectUnauthorized:false,
    };

  var checkConnRequest = https.request(https_checkConn,function(res)
  {
    var bodyChunks =[];
    res.on('data',function(chunk)
    {
      bodyChunks.push(chunk);
    }).on('end',function()
    {
      var body = Buffer.concat(bodyChunks);
      if(body.toString()=='true')
      {
        console.log("Added "+node.hostname+":"+node.port+" to queue");
        node_queue.push(node);
      }
    });
  });

  checkConnRequest.on('error',function(err)
{
  console.log("Error connecting to "+node.hostname+":"+node.port);

});
checkConnRequest.end();

  }
}

var job_queue = [];
if(process.env.mode !== "TESTING")
{
  server.listen(nodes_data.host_port.port);
  console.log("Listening at "+nodes_data.host_port.port);
}



setInterval(function () {
  connection.query('SELECT 1' ,function(err, rows, fields) {
    console.log("keep alive query");
  });
}, 10000);


module.exports ={
  app:app,
  server:server,
  node_queue:node_queue,
  job_queue:job_queue
}
