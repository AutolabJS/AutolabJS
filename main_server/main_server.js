"use strict";

var fs = require("fs");
var express = require("express");
var app = express();
var path = require("path");

var https_config = {
key: fs.readFileSync("./ssl/key.pem"),
cert: fs.readFileSync("./ssl/cert.pem"),
rejectUnauthorized: false
};
var httpolyglot = require("httpolyglot");
var https = require("https");

var server = httpolyglot.createServer(https_config, app);
var io = require("socket.io")(server);
var session = require("express-session")({
  secret: "Autolab",
  httpOnly: true,
  secure: true,
  resave: true,
  saveUninitialized: true
});

var socketSession = require("express-socket.io-session");
var bodyParser = require("body-parser");
var config_details = require("/etc/main_server/conf.json");
var mysql = require("mysql");

var lab_config = require("/etc/main_server/labs.json");
var course_details = require("/etc/main_server/courses.json");
var APIKeys_details = require("/etc/main_server/APIKeys.json");

app.use(session);
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, "/public")));

var load_balancer_hostname = config_details.load_balancer.hostname;
var load_balancer_port = config_details.load_balancer.port;

var connection = mysql.createConnection(
  config_details.database
);

connection.connect();

function initLabs()
{
  lab_config.Labs.forEach(function(lab)
  {
    initScoreboard(lab.Lab_No);
  });
}

function initScoreboard(lab_no){
  var table_name = "l" + lab_no;
  connection.query("SELECT * FROM information_schema.tables WHERE table_schema = ? AND table_name = ? LIMIT 1", [config_details.database.database, table_name], function(err, rows, fields){
    if (err)
    {
      console.log("Error fetching lab tables " + err);
    }
    else if (typeof rows === "undefined" || rows.length === 0)
    {
      var q = "CREATE TABLE l" + lab_no + "(id_no varchar(12), score int, time datetime)";
      connection.query(q, function(err, rows, fields){
        if (err)
        {
          console.log("Error creating the scoreboard " + err);
        }
      });
    }
  });
}

initLabs();

setInterval(function () {
  connection.query("SELECT 1", function (err, rows, fields) {
    if (err) {
      console.log("Error connecting to the database");
    } else {
      console.log("keep alive query");
    }
  });
}, 10000);

server.listen(config_details.host_port.port);
console.log("Listening at " + config_details.host_port.port);

app.use("/", express.static(path.join(__dirname, "/public")));

var submission_pending = [];  // Holds the pending submissions of the users

app.get("/admin", function (req, res) {
  res.sendFile(path.join(__dirname, "/public/admin.html"));
});

app.get("/config", function(req, res)
{
  console.log("Request Session");
  console.log(req.session);
    if (!req.session.key) {res.redirect("/admin");}
    else {res.sendFile(path.join(__dirname, "/public/config.html"));}
});

app.get("/revaluation/download/:lab", function(req, res)
{
  if (!req.session.key) {res.redirect("/admin");}
  var lab = req.params.lab;
  res.download("./reval/" + lab + "_reval_score.csv");
});

app.get("/", function(req, res){
  console.log("index.html requested");
  res.send("./public/index.html");
});

app.post("/results", function(req, res){
  console.log("Results post request received");
  console.log(req.body);
  res.send("true");
  submission_pending.splice(submission_pending.indexOf(req.body.id_no, 1));
  console.log("remove Users");
  io.to(req.body.socket).emit("scores", req.body);
});

app.get("/scoreboard/:Lab_no", function(req, res){
  console.log("Scoreboard requested");
  var lab = req.params.Lab_no;
  var labFound = false;
  lab_config.Labs.forEach(function(lab_available){
    if (lab_available.Lab_No === lab)
    {
      labFound = true;
    }
  });
  if (labFound)
  {
    connection.query("SELECT id_no, score, TIME(time) AS time FROM l" + lab + " ORDER BY score DESC, time", function(err, rows, fields){
      res.send(rows);
    });
  }
  else
  {
    res.send(false);
  }
});

//status requested
app.get("/status", function(statusReq, statusRes){
  console.log("Status requested");
  //options for load_balancer get request
  var options = {
  host: load_balancer_hostname,
  port: load_balancer_port,
  path: "/connectionCheck",
  key: fs.readFileSync("./ssl/key.pem"),
  cert: fs.readFileSync("./ssl/cert.pem"),
  rejectUnauthorized: false
  };
  //send a get request and capture the response
  var req = https.request(options, function(res){
  //Buffer the body entirely for processing as a whole.
    var bodyChunks = [];
    res.on("data", function(chunk){
      bodyChunks.push(chunk);
    }).on("end", function(){

      var body = Buffer.concat(bodyChunks);
      var result = "";
      result = result.concat(body);
      statusRes.send(result);
      });
  });
  req.on("error", function(e){
    statusRes.send("Load Balancer Error: " + e.message);
    console.log("Load Balancer Error: " + e.message);
  });
req.end();
});

io.use(socketSession(session, {
  autoSave: true
}));

io.on("connection", function(socket){
  require("./admin.js")(socket);
  var current_time = new Date();
  var start;
  var end;
  var hard;
  var labs_status = [];
  lab_config.Labs.forEach(function(lab_available){
    start = new Date(lab_available.start_year, lab_available.start_month -1, lab_available.start_date, lab_available.start_hour, lab_available.start_minute, 0, 0);
    end = new Date(lab_available.end_year, lab_available.end_month -1, lab_available.end_date, lab_available.end_hour, lab_available.end_minute, 0, 0);
    hard = new Date(lab_available.hard_year, lab_available.hard_month -1, lab_available.hard_date, lab_available.hard_hour, lab_available.hard_minute, 0, 0);
    var status = 0;
    if (current_time - start > 0)
    {
      if (current_time - end < 0)
      {
        var delta = Math.abs((end - current_time) / 1000);
        status = 1;
      }
      else {
        if (current_time - hard < 0)
        {
          status = 2;
        }
      }
    }
    var lab_x = {"Lab_No": lab_available, "status": status};
    labs_status.push(lab_x);
  });

  //emit course name,number and instructors
  socket.emit("course details", course_details);

  //emit lab status
  socket.emit("labs_status", labs_status);

  socket.on("submission", function(data){
    console.log("Socket submission event triggered");
    var APIKeys = APIKeys_details.keys;
    var id_number = data[0];
    var lab_no = data[1];
    var commit_hash = data[2];
    var language = data[3];
    var labFound = false;
    var penalty = 0;
    var curr_penalty = 0;
    var admin_key = null;
    if (data.length === 5) {admin_key = data[4];}
    if ((admin_key === null || APIKeys.indexOf(admin_key) ===-1 ) && submission_pending.indexOf(id_number) !== -1)       // Check if there is a pending submission
    {
      console.log("Pending Submission request " + admin_key);                                                // with the same Non-Admin ID number
      io.to(socket.id).emit("submission_pending", {});
      return false;
    }
    else
    {
      submission_pending.push(id_number);
      console.log("New request");

      lab_config.Labs.forEach(function(lab_available){
        if (lab_available.Lab_No === lab_no)
        {
          start = new Date(lab_available.start_year, lab_available.start_month -1, lab_available.start_date, lab_available.start_hour, lab_available.start_minute, 0, 0);
          end = new Date(lab_available.end_year, lab_available.end_month -1, lab_available.end_date, lab_available.end_hour, lab_available.end_minute, 0, 0);
          hard = new Date(lab_available.hard_year, lab_available.hard_month -1, lab_available.hard_date, lab_available.hard_hour, lab_available.hard_minute, 0, 0);
          labFound = true;
          curr_penalty = lab_available.penalty;
        }
      });
      id_number = id_number.replace(/s+/, "");
      commit_hash = commit_hash.replace(/s+/, "");

      if (labFound)
      {
        var status = 0;
        if (current_time - start > 0)
        {
          if (current_time - end < 0)
          {
            status = 1;
          }
          else
          {
            if (current_time - hard < 0)
            {
              status = 2;
              penalty = curr_penalty;
            }
          }
        }
        var body_json = {
          "id_no": id_number.toUpperCase(),
          "Lab_No": lab_no,
          "time": current_time.toISOString().slice(0, 19).replace("T", " "),
          "commit": commit_hash,
          "status": status,
          "penalty": penalty,
          "socket": socket.id,
          "language": language
        };

        var body = JSON.stringify(body_json);
        var request = https.request({
          hostname: load_balancer_hostname,
          port: load_balancer_port,
          path: "/submit",
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Content-Length": Buffer.byteLength(body)
          },
          key: fs.readFileSync("./ssl/key.pem"),
          cert: fs.readFileSync("./ssl/cert.pem"),
          rejectUnauthorized: false
          });
        request.end(body);
        request.on("error", function(e){
          console.log(e);
          socket.emit("invalid", "Invalid Lab No");
        });
      }
      else {
      socket.emit("invalid", "Invalid Lab No");
      }
    }
  });

  socket.emit("lab_data",
  {
    course: fs.readFileSync("/etc/main_server/courses.json").toString("utf-8"),
    lab: fs.readFileSync("/etc/main_server/labs.json").toString("utf-8")
  });

  socket.on("save", function(data)
  {
    if (!socket.handshake.session.key)
      return;
    var lab = {
      Labs: data.labs
    };

    data.labs.forEach(function(lab_available)
    {
      if (!(lab_available.Lab_No === "" || lab_available.Lab_No === undefined))
          {
            initScoreboard(lab_available.Lab_No);
          }
    });
    fs.writeFile("/etc/main_server/labs.json", JSON.stringify(lab, null, 4));
    fs.writeFile("/etc/main_server/courses.json", JSON.stringify(data.course, null, 4));
    socket.emit("saved");
    });

  socket.on("delete lab", function(tableName)
  {
    if (!socket.handshake.session.key)
      return;
    connection.query("DROP TABLE l" + tableName, function(err, rows, fields) {
      console.log(err, rows, fields);

      if (rows !== undefined && rows.length !== 0)
      {
        var lab_data = JSON.parse(fs.readFileSync("/etc/main_server/labs.json").toString());
        for (var i in lab_data.Labs)
        {
          if (lab_data.Labs[i].Lab_No === tableName)
            lab_data.Labs.splice(i, 1);
        }
        fs.writeFileSync("/etc/main_server/labs.json", JSON.stringify(lab_data, null, 4));
        socket.emit("deleted");
      }
    });
  });

  socket.on("disconnect", function()
  {
    console.log("DISCONNECTED");
  });
});

module.exports.app = app;
module.exports.server = server;
module.exports.connection = connection;
