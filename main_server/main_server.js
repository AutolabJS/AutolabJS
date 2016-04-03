var express = require('express');
var app = express();
var server = require('http').createServer(app);
var http = require('http');
var bodyParser = require('body-parser');
var fs = require('fs');
var io = require('socket.io')(server);
var config_details = require('./conf.json');
var mysql = require('mysql');

app.use(express.static(__dirname + '/public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

var load_balancer_hostname=config_details["load_balancer"].hostname;
var load_balancer_port=config_details["load_balancer"].port;

var connection = mysql.createConnection(
  config_details["database"]
);

connection.connect();

function initLabs()
{
  lab_config = require('./labs.json');
  for(var j=0;j<lab_config["Labs"].length;j++)
  {
    initScoreboard(lab_config["Labs"][j].Lab_No);
  }
}

function initScoreboard(lab_no) {
  table_name='l'+lab_no;
  connection.query('SELECT * FROM information_schema.tables WHERE table_schema = ? AND table_name = ? LIMIT 1', [config_details["database"].database,table_name] ,function(err, rows, fields) {
      if(rows.length==0)
      {
        var q='CREATE TABLE l'+lab_no+'(id_no varchar(12), score int, time datetime)';
        connection.query(q, function(err, rows, fields) {
        });
      }
  });
}

initLabs();
server.listen(8080);
console.log("Listening at 8080");

app.get('/', function (req,res) {
  res.send('./public/index.html');
});

app.post('/results', function(req, res){
  console.log(req.body);
  res.send(true);
  io.to(req.body.socket).emit('scores', req.body.marks);
});

app.get('/scoreboard/:Lab_no', function(req, res) {
  lab = req.params.Lab_no;
  flag=0;
  lab_conf = require('./labs.json');
  for(var i=0;i<lab_conf["Labs"].length;i++) {
    if(lab_conf["Labs"][i].Lab_No == lab)
    {
      flag=1;
      break;
    }
  }
  if(flag == 1)
  {
    connection.query('SELECT * FROM l'+lab+' ORDER BY score DESC, time' ,function(err, rows, fields) {
      res.send(rows);
    });
  }
  else {
    res.send(false);
  }
});

io.on('connection', function(socket) {
  lab_conf = require('./labs.json');
  var current_time= new Date();
  labs_status=[];
  for(var i=0;i<lab_conf["Labs"].length;i++) {
    start=new Date(lab_conf["Labs"][i].start_year, lab_conf["Labs"][i].start_month -1 ,lab_conf["Labs"][i].start_date, lab_conf["Labs"][i].start_hour,lab_conf["Labs"][i].start_minute, 0,0);
    end=new Date(lab_conf["Labs"][i].end_year, lab_conf["Labs"][i].end_month -1 ,lab_conf["Labs"][i].end_date, lab_conf["Labs"][i].end_hour,lab_conf["Labs"][i].end_minute, 0,0);
    hard=new Date(lab_conf["Labs"][i].hard_year, lab_conf["Labs"][i].hard_month -1 ,lab_conf["Labs"][i].hard_date, lab_conf["Labs"][i].hard_hour,lab_conf["Labs"][i].hard_minute, 0,0);
    var status = 0;
    if(current_time-start > 0)
    {
      if(current_time - end < 0)
      {
        status=1;
      }
      else {
        if(current_time - hard < 0)
        {
          status =2;
        }
      }
    }

    lab_x = {"Lab_No" :lab_conf["Labs"][i], "status": status};
    labs_status.push(lab_x);
  }
  socket.emit('labs_status', labs_status);

  socket.on('submission', function(data) {
    id_number=data[0];
    lab_no=data[1];
    current_time = new Date();
    lab_config = require('./labs.json');
    flag=0;
    penalty=0;
    for(var i=0;i<lab_config["Labs"].length;i++) {
      if(lab_config["Labs"][i].Lab_No == lab_no)
      {
        start=new Date(lab_config["Labs"][i].start_year, lab_config["Labs"][i].start_month -1 ,lab_config["Labs"][i].start_date, lab_config["Labs"][i].start_hour,lab_config["Labs"][i].start_minute, 0,0);
        end=new Date(lab_config["Labs"][i].end_year, lab_config["Labs"][i].end_month -1 ,lab_config["Labs"][i].end_date, lab_config["Labs"][i].end_hour,lab_config["Labs"][i].end_minute, 0,0);
        hard=new Date(lab_config["Labs"][i].hard_year, lab_config["Labs"][i].hard_month -1 ,lab_config["Labs"][i].hard_date, lab_config["Labs"][i].hard_hour,lab_config["Labs"][i].hard_minute, 0,0);
        flag=1;
        break;
      }
    }
    if(flag==1) {
      var status = 0;
      if(current_time-start > 0)
      {
        if(current_time - end < 0)
        {
          status=1;
        }
        else {
          if(current_time - hard < 0)
          {
            status =2;
            penalty=lab_config["Labs"][i].penalty;
          }
        }
      }
      body_json= {"id_no" :id_number, "Lab_No": lab_no, "time":current_time.toISOString().slice(0, 19).replace('T', ' '), "status": status, "penalty": penalty, "socket": socket.id};
      var body=JSON.stringify(body_json);
      var request = new http.ClientRequest({
        hostname: load_balancer_hostname,
        port: load_balancer_port,
        path: "/submit",
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(body)
        }
      });
      request.end(body);
    }
    else {
      socket.emit("invalid", "Invalid Lab No");
    }
  });
});
