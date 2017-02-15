"use strict";
var fs = require("fs");
var express = require("express");
var app = express();
var https_config = {
  key : fs.readFileSync("./ssl/key.pem"),
  cert: fs.readFileSync("./ssl/cert.pem"),
  rejectUnauthorized: false
};
var https = require("https");
var httpolyglot = require("httpolyglot");
var server = httpolyglot.createServer(https_config, app);
var bodyParser = require("body-parser");
var exec = require("child_process").exec;
var mysql = require("mysql");

var nodes_data = require("/etc/load_balancer/nodes_data_conf.json");
var server_hostname = nodes_data.server_info.hostname;
var server_port = nodes_data.server_info.port;
var gitlab_hostname = nodes_data.gitlab.hostname;
var node_queue = [];
var job_queue = [];
var i;

var connection = mysql.createConnection(nodes_data.database);

server.listen(nodes_data.host_port.port);
console.log("Listening at " + nodes_data.host_port.port);

app.use(bodyParser.json());

function checkNodeConn(node) {
  var resultString = "",
    https_checkConn = {
      host: node.hostname,
      port: node.port,
      path: "/connectionCheck",
      key : fs.readFileSync("./ssl/key.pem"),
      cert: fs.readFileSync("./ssl/cert.pem"),
      rejectUnauthorized: false
    },
  //send a get request and capture the response
    checkConnRequest = https.request(https_checkConn, function (res) {
      var bodyChunks = [];
      res.on("data", function (chunk) {
        bodyChunks.push(chunk);
      }).on("end", function () {
        var body = Buffer.concat(bodyChunks);
        resultString = resultString.concat("Execution Node at " + node.hostname + ":" + node.port + " working: " + body + "\n");
        console.log("nodeing");
        return resultString;
      });
    });

  checkConnRequest.on("error", function (e) {
    resultString = resultString.concat("Execution Node at  " + node.hostname + ":" + node.port + " Error: " + e.message + "\n");
    return resultString;
  });
  checkConnRequest.end();
}

function connectToSQL() {
  connection.query("SELECT 1", function (err, rows, fields) {
    if (!err) {
      console.log("Keep alive Query");
    } else {
      connection.connect(function (err) {
        if (!err) {
          console.log("Connected to Database");
        } else {
          console.log("Error connecting to database." + err);
        }
      });
    }
  });
}

app.get("/userCheck", function (req, res) {
  console.log("userCheck requested");
  res.send(true);
});

app.get("/connectionCheck", function (req, res) {
  console.log("connectionCheck requested");
  var result_connectionCheck = "Load Balancer Working\n";

  for (i = 0; i < nodes_data.Nodes.length; i = i + 1) {
    console.log(nodes_data.Nodes.length - i);
    result_connectionCheck = result_connectionCheck + checkNodeConn(nodes_data.Nodes[i]);
  }

  res.send(result_connectionCheck);
});

app.post("/submit", function (req, res) {
  console.log("submit post request recieved");
  console.log(req.body);
  res.send(true);

  if (node_queue.length !== 0) {
    console.log(node_queue.length + " " + job_queue.length);
    var assigned_node = node_queue.pop(),
      assigned_hostname = assigned_node.hostname,
      assigned_port = assigned_node.port,
      body = JSON.stringify(req.body),
      https_job_options = {
        hostname: assigned_hostname,
        port: assigned_port,
        path: "/requestRun",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(body)
        },
        key : fs.readFileSync("./ssl/key.pem"),
        cert: fs.readFileSync("./ssl/cert.pem"),
        rejectUnauthorized: false
      },

      request = https.request(https_job_options, function (response) {
        response.on("data", function (chunk) {
          console.log(chunk);
        });
      });

    request.on("error", function (error) {
      console.log(error);
    });

    request.end(body);
  } else {
    job_queue.push(req.body);
  }
});

app.post("/sendScores", function (req, res) {
  console.log("sendScores post request recieved");
  var submission_json = req.body.submission_details,
    node_json = req.body.node_details,
    array = submission_json.marks,
    body = "",
    assigned_node,
    assigned_hostname,
    assigned_port,
    https_options,
    https_job_options,
    request_pendingJob,
    request,
    q,
    q1,
    q2,
    exec_command,
    total_score = 0,
    code_download_flag = 0,
    table_name = "l" + submission_json.Lab_No;
  node_queue.push(node_json);
  res.send(true);

  if (job_queue.length !== 0) {
    body = JSON.stringify(job_queue.pop());
    assigned_node = node_queue.pop();
    assigned_hostname = assigned_node.hostname;
    assigned_port = assigned_node.port;
    https_options = {
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync("./ssl/key.pem"),
      cert: fs.readFileSync("./ssl/cert.pem"),
      rejectUnauthorized: false
    };

    request_pendingJob = https.request(https_options, function (response) {
      response.on("data", function (chunk) {
        console.log(chunk);
      });
    });
    request_pendingJob.on("error", function (error) {
      console.log(error);
    });
    request_pendingJob.end(body);
  }

  body = JSON.stringify(submission_json);
  https_job_options = {
    hostname: server_hostname,
    port: server_port,
    path: "/results",
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(body)
    },
    key : fs.readFileSync("./ssl/key.pem"),
    cert: fs.readFileSync("./ssl/cert.pem"),
    rejectUnauthorized: false
  };

  request = https.request(https_job_options, function (response) {
    response.on("data", function (chunk) {
      console.log(chunk);
    });
  });
  request.on("error", function (error) {
    console.log(error);
  });
  request.end(body);

  //calculation of total marks begins
  if ((submission_json.status ===  1) || (submission_json.status === 2)) {
    q = "SELECT * FROM " + table_name + " WHERE id_no = \"" + submission_json.id_no + "\"";

    for (i = 0; i < array.length; i = i + 1) {
      total_score = total_score + parseInt(array[i], 10);
    }

    total_score = total_score - parseInt(submission_json.penalty, 10);

    if (total_score < 0) {
      total_score = 0;
    }

    connection.query(q, function (err, rows, fields) {
      if (rows.length === 0) {
        q1 = "INSERT INTO " + table_name + " VALUES (\"" + submission_json.id_no + "\", " + total_score + ",\"" + submission_json.time + "\")";
        connection.query(q1, function (err, rows, fields) {
          console.log(err);
        });
        code_download_flag = 1;
      } else {
        if (rows[0].score < total_score) {
          q2 = "UPDATE " + table_name + " SET score =" + total_score + ", time = \"" + submission_json.time + "\" WHERE id_no = \"" + submission_json.id_no + "\"";
          connection.query(q2, function (err, rows, fields) {
            console.log(err);
          });
          code_download_flag = 1;
        }
      }

      if (code_download_flag === 1) {
        exec_command = "bash savecode.sh ";
        exec_command = exec_command.concat(submission_json.id_no + " " + submission_json.Lab_No + " " + gitlab_hostname + " " + submission_json.commit);
        exec(exec_command, function (error, stdout, stderr) {
          console.log(error);
          console.log(stdout);
          console.log(stderr);
        });
      }
      if (err) {
        console.log(err);
      }
    });
  }
});

app.post("/addNode", function (req, res) {
  console.log("addNode post request recieved");
  res.send(true);
  var node,
    assigned_node,
    assigned_hostname,
    assigned_port,
    body,
    https_job_options,
    request;
  // Check if the Execution node is already accounted for in the queue,return if it is.
  for (node = 0; node < node_queue.length; node = node + 1) {
    if ((node_queue[node].hostname === req.body.hostname) && (node_queue[node].port === req.body.port)) {
      return;
    }
  }

  console.log(req.body);
  node_queue.push(req.body);
  console.log("Added " + req.body.hostname + ":" + req.body.port + " to queue");

  if (job_queue.length !== 0) {
    assigned_node = node_queue.pop();
    assigned_hostname = assigned_node.hostname;
    assigned_port = assigned_node.port;
    body = JSON.stringify(job_queue.pop());
    https_job_options = {
      hostname: assigned_hostname,
      port: assigned_port,
      path: "/requestRun",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(body)
      },
      key : fs.readFileSync("./ssl/key.pem"),
      cert: fs.readFileSync("./ssl/cert.pem"),
      rejectUnauthorized: false,
    };

    request = https.request(https_job_options, function (response) {
      response.on("data", function (chunk) {
        console.log(chunk);
      });
    });
    request.on("error", function (error) {
      console.log(error);
    });
    request.end(body);

  }
});

for (i = 0; i < nodes_data.Nodes.length; i = i + 1) {
  console.log(checkNodeConn(nodes_data.Nodes[i]));
}

setInterval(connectToSQL, 1000);

module.exports = {
  app: app,
  server: server,
  node_queue: node_queue,
  job_queue: job_queue
};