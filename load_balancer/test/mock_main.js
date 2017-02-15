var fs = require('fs');
var express = require('express');
var path = require('path');
var app = express();
var https = require('https');
var https_config={
  key : fs.readFileSync('./ssl/key.pem'),
  cert: fs.readFileSync('./ssl/cert.pem'),
  rejectUnauthorized:false,
};
var httpolyglot = require('httpolyglot');

//redirect to https


var server = httpolyglot.createServer(https_config,app);

var bodyParser = require('body-parser');

var io = require('socket.io')(server);
var session = require('express-session')({
  secret:"Autolab",
  httpOnly:true,
  secure:true,
  resave:true,
  saveUninitialized:true
});

app.use(session);
var socketSession = require('express-socket.io-session')

var config_details = require('./config/conf.json');
var mysql = require('mysql');

app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());




var load_balancer_hostname=config_details.load_balancer.hostname;
var load_balancer_port=config_details.load_balancer.port;

var connection = require('./database.js');


//Start the server if not running tests on the main server
if(process.env.mode !== "TESTING")
{
    server.listen(config_details.host_port.port);
    console.log("Listening at "+config_details.host_port.port);
}

// Redirection from HTTP to HTTPS for all the routes.
app.use(function(req,res,next)
{

  if(req.protocol=='http')
  {

    res.redirect('https://' + req.get('host') + req.originalUrl);

  }

  else
    {

      next()
    }
})


app.use('/',express.static(__dirname + '/public'));


var submission_pending = [];  // Holds the pending submissions of the users



// app.get('/', function (req,res) {


//   res.sendFile(path.join(__dirname + '/public/index.html'));

// });


app.get('/admin', function (req,res) {

  res.sendFile(path.join(__dirname+ '/public/admin.html'));

});


app.get('/config',function(req,res)
{
  console.log("Request Session")
  console.log(req.session)
    if(!req.session.key) res.redirect('/admin')
    else res.sendFile(path.join(__dirname+ '/public/config.html'));
});


app.get('/revaluation/download/:lab',function(req,res)
{
  if(!req.session.key) res.redirect('/admin')
  var lab = req.params.lab;
  // var file = fs.createReadStream('./reval/'+lab+'_reval_score.csv');
  // file.pipe(res);

  res.download('./reval/'+lab+'_reval_score.csv');


});

app.post('/results', function(req, res){
  console.log('Results post request received');
  console.log(req.body);
  res.send("true");
  submission_pending.splice(submission_pending.indexOf(req.body.id_no,1));
  console.log('remove Users');
  io.to(req.body.socket).emit('scores', req.body);
});



io.on('connection', function(socket) {
  require('./admin.js')(socket)

  lab_conf = require('./config/labs.json');
  var current_time= new Date();
  labs_status=[];
  for(var i=0;i<lab_conf.Labs.length;i++) {
    start=new Date(lab_conf.Labs[i].start_year, lab_conf.Labs[i].start_month -1 ,lab_conf.Labs[i].start_date, lab_conf.Labs[i].start_hour,lab_conf.Labs[i].start_minute, 0,0);
    end=new Date(lab_conf.Labs[i].end_year, lab_conf.Labs[i].end_month -1 ,lab_conf.Labs[i].end_date, lab_conf.Labs[i].end_hour,lab_conf.Labs[i].end_minute, 0,0);
    hard=new Date(lab_conf.Labs[i].hard_year, lab_conf.Labs[i].hard_month -1 ,lab_conf.Labs[i].hard_date, lab_conf.Labs[i].hard_hour,lab_conf.Labs[i].hard_minute, 0,0);
    var status = 0;
    if(current_time-start > 0)
    {
      if(current_time - end < 0)
      {
        delta = Math.abs((end - current_time) / 1000);
        status=1;
      }
      else {
        if(current_time - hard < 0)
        {
          status =2;
        }
      }
    }

    lab_x = {"Lab_No" :lab_conf.Labs[i], "status": status};
    labs_status.push(lab_x);
  }
  //emit course name,number and instructors
  socket.emit('course details',require('./config/courses.json'));

  //emit lab status
  socket.emit('labs_status', labs_status);

  socket.on('submission', function(data) {
    console.log('Socket submission event triggered');
    id_number=data[0];
    lab_no=data[1];
    commit_hash=data[2];
    if(submission_pending.indexOf(id_number)!=-1)      // Check if there is a pending submission
    {                                                   // with the same ID number
      io.to(socket.id).emit('submission_pending',{});
       return false;
    }
    else
      {
        submission_pending.push(id_number);
         console.log("New request");
        current_time = new Date();
        lab_config = require('./config/labs.json');
        flag=0;
        penalty=0;
        for(var i=0;i<lab_config.Labs.length;i++) {
          if(lab_config.Labs[i].Lab_No == lab_no)
          {
            start=new Date(lab_config.Labs[i].start_year, lab_config.Labs[i].start_month -1 ,lab_config.Labs[i].start_date, lab_config.Labs[i].start_hour,lab_config.Labs[i].start_minute, 0,0);
            end=new Date(lab_config.Labs[i].end_year, lab_config.Labs[i].end_month -1 ,lab_config.Labs[i].end_date, lab_config.Labs[i].end_hour,lab_config.Labs[i].end_minute, 0,0);
            hard=new Date(lab_config.Labs[i].hard_year, lab_config.Labs[i].hard_month -1 ,lab_config.Labs[i].hard_date, lab_config.Labs[i].hard_hour,lab_config.Labs[i].hard_minute, 0,0);
            flag=1;
            break;
          }
        }
        id_number = id_number.replace(/\s+/, "");
        commit_hash = commit_hash.replace(/\s+/, "");
        if(/^\w+$/.test(id_number)===false)
        {
          flag=0;
        }
        if(/^\w*$/.test(commit_hash)===false)
        {
          flag=0;
        }
        if(id_number.length!=12)
        {
          flag=0;
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
                penalty=lab_config.Labs[i].penalty;
              }
            }
          }
          body_json= {"id_no" :id_number.toUpperCase(), "Lab_No": lab_no, "time":current_time.toISOString().slice(0, 19).replace('T', ' '), "commit": commit_hash, "status": status, "penalty": penalty, "socket": socket.id};

          var options = {
            host: load_balancer_hostname,
            port: load_balancer_port,
            path: '/userCheck',
            key : fs.readFileSync('./ssl/key.pem'),
            cert: fs.readFileSync('./ssl/cert.pem'),
            rejectUnauthorized:false,
          };
          var body=JSON.stringify(body_json);
          var request = https.request({
            hostname: load_balancer_hostname,
            port: load_balancer_port,
            path: "/submit",
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Content-Length": Buffer.byteLength(body)
            },
            key : fs.readFileSync('./ssl/key.pem'),
            cert: fs.readFileSync('./ssl/cert.pem'),
            rejectUnauthorized:false,
          });
          request.end(body);
          request.on('error', function(e) {
            console.log(e);
            socket.emit("invalid", "Invalid Lab No");
          });
        }
        else {
          socket.emit("invalid", "Invalid Lab No");
        }
      }

  });



  socket.emit('lab_data',
  {
    course:fs.readFileSync('./config/courses.json').toString('utf-8'),
    lab:fs.readFileSync('./config/labs.json').toString('utf-8')
  });


  socket.on('save',function(data)
  {
    if(!socket.handshake.session.key) return;

    var lab = {
      Labs: data.labs
    };

    for(var i in data.labs)
    {
      if(!(data.labs[i]["Lab_No"]=== "" || data.labs[i]["Lab_No"] === undefined ))
        {
          initScoreboard(data.labs[i]["Lab_No"]);
        }
    }
    fs.writeFile('./config/labs.json',JSON.stringify(lab,null,4));
    fs.writeFile('./config/courses.json',JSON.stringify(data.course,null,4));

    socket.emit("saved");
  });


  socket.on('delete lab',function(tableName)
  {
    if(!socket.handshake.session.key) return;
    connection.query(' DROP TABLE l'+tableName, function(err, rows, fields) {

      console.log(err,rows,fields)
      if(process.env.mode === "TESTING" || (rows!=undefined && rows.length!==0))
      {
        var lab_data = JSON.parse(fs.readFileSync('./config/labs.json').toString());

        for(var i=0;i<lab_data.Labs.length;i++)
        {
          if(lab_data["Labs"][i]["Lab_No"] == tableName) lab_data["Labs"].splice(i,1);
        }

        fs.writeFileSync('./config/labs.json',JSON.stringify(lab_data,null,4));
        socket.emit('deleted');
      }
  });

  })
});


module.exports.app = app;
module.exports.server = server;
module.exports.connection = connection;
