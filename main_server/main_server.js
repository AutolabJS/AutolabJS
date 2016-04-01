var express = require('express');
var app = express();
var server = require('http').createServer(app);
var http = require('http');
var bodyParser = require('body-parser');
var fs = require('fs');
var io = require('socket.io')(server);
var config_details = require('./conf.json');
var lab_config = require('./labs.json');
var mysql = require('mysql');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

app.get('/connectionCheck', function (req,res) {
  res.send(true);
});

app.post('/results', function(req, res){
    var submission_id = req.body.id;
    var scores = req.body.marks;
    console.log(submission_id+ " "+scores);
    res.send(true);
});

app.get('/', function (req,res) {
    res.send('./public/index.html');
});


var load_balancer_hostname=config_details["load_balancer"].hostname;
var load_balancer_port=config_details["load_balancer"].port;

var connection = mysql.createConnection(
  config_details["database"]
);

connection.connect();

for(var i=0;i<lab_config["Labs"].length;i++)
{
  initDB(lab_config["Labs"][i].Lab_No,i);
}

function initDB(lab_no,i) {
  status=false
  connection.query('SELECT * FROM Labs WHERE Lab_No=?', [lab_no] ,function(err, rows, fields) {
      if(rows.length==0)
      {
        var q='CREATE TABLE l'+lab_no+'(name int)';
        connection.query(q, function(err, rows, fields) {
            if(err) throw err;
        });
        q2="INSERT INTO Labs VALUES ("+lab_no+","+lab_config["Labs"][i].start_time+","+lab_config["Labs"][i].end_time+","+lab_config["Labs"][i].hard_deadline+","+lab_config["Labs"][i].penalty+","+lab_config["Labs"][i].testcases+","+status+")";
        connection.query(q2,function(err,rows, fields) {
            if (err) throw err;
        });
      }
      else {
        q3="UPDATE Labs SET start_time="+lab_config["Labs"][i].start_time+", end_time="+lab_config["Labs"][i].end_time+", hard_deadline="+lab_config["Labs"][i].hard_deadline+", penalty="+lab_config["Labs"][i].penalty+", test_cases="+lab_config["Labs"][i].testcases+", status="+status+" WHERE Lab_No="+lab_no;
        // console.log(q3);
        connection.query(q3,function(err,rows, fields) {
            if (err) throw err;
        });
      }
  });
}

server.listen(8080);
console.log("Listening at 8080");

// io.on('connection', function(socket) {
//   console.log('A user has connected.');
// });
