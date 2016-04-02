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
var mysql = require('mysql');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/requestRun', function(req, res){
  res.send(true);
  var submission_id = req.body.id_no;
  var exec_command = 'sh extract_run.sh ';
  exec_command = exec_command.concat(submission_id);
  exec(exec_command,function (error, stdout, stderr) {
    var array = fs.readFileSync('submissions/'+submission_id+'/scores.txt').toString().split("\n");
    exec('sh cleanup.sh '.concat(submission_id));
    array.pop(); //remove last space
    console.log(array);
    var body=scores;
    body["submission_details"].id_no=submission_id;
    body["submission_details"].marks=array;
    body["submission_details"].Lab_No=req.body.Lab_No;
    body["submission_details"].time=req.body.time;
    body["submission_details"].status=req.body.status;
    body["submission_details"].penalty=req.body.penalty;
    // body["submission_details"].socket=req.body.socket;
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
    if(req.body.status ==  1 || req.body.status == 2)
    {
      total_score = 0;

      table_name='l'+req.body.Lab_No;
      console.log("Inserting "+submission_id+" in "+ table_name+" at "+ req.body.time);

      // connection.query('SELECT * FROM ? WHERE id=?',[table_name, req.body.submission_id] ,function(err, rows, fields) {
      //   if(rows.length==0)
      //   {
      //     console.log("Inserting "+req.body.submission_id+" in "+ table_name+" at "+ req.body.time);
      //     // var q='INSERT INTO '+table_name+' VALUES ('+req.body.submission_id+', '+ total_score+','+time+')';
      //     // connection.query(q, function(err, rows, fields) {
      //     // });
      //   }
      //   else {
      //     //update
      //   }
      // });
    }
  });
});


load_balancer_hostname=conf["load_balancer"].hostname;
load_balancer_port=conf["load_balancer"].port;

var connection = mysql.createConnection(
  conf["database"]
);

connection.connect();


server.listen(8082);
console.log("Listening at 8082");
