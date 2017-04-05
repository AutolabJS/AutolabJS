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
var http = require("http");
var bodyParser = require("body-parser");
var exec = require("child_process").exec;
var nodes_data = require("/etc/load_balancer/nodes_data_conf.json");
var mysql = require("mysql");

var node_queue = [];
var job_queue = [];
var server_hostname = nodes_data.server_info.hostname;
var server_port = nodes_data.server_info.port;
var gitlab_hostname = nodes_data.gitlab.hostname;
var gitlab_port = nodes_data.gitlab.port;
var connection;
var i;

server.listen(nodes_data.host_port.port);
console.log("Listening at " + nodes_data.host_port.port);

app.use(bodyParser.json());

app.get("/userCheck", function (req, res) {
  console.log("userCheck requested");
  res.send(true);
});

app.get("/connectionCheck", function (req, res) {
  console.log("connectionCheck requested");
  var result = "Load Balancer Working\n",
    numOfNodes = nodes_data.Nodes.length;

  function dispResult() {
    res.send(result);
  }

  function checkNodeConn(node) {
    var options = {
      host: node.hostname,
      port: node.port,
      path: "/connectionCheck",
      key : fs.readFileSync("./ssl/key.pem"),
      cert: fs.readFileSync("./ssl/cert.pem"),
      rejectUnauthorized: false
    },
    //send a get request and capture the response
      req_checkNodeConn = https.request(options, function (res) {
      // Buffer the body entirely for processing as a whole.
        var bodyChunks = [];
        res.on("data", function (chunk) {
          bodyChunks.push(chunk);
        }).on("end", function () {
          var body = Buffer.concat(bodyChunks);
          result = result.concat("<br/>Execution Node at " + node.hostname + ":" + node.port + " working: " + body);
          console.log("nodeing");
          //return if all requets processed
          numOfNodes = numOfNodes - 1;
          if (numOfNodes === 0) {
            console.log("DispRes");
            dispResult();
          }
        });
      });
    req_checkNodeConn.on("error", function (e) {
      result = result.concat("<br/>Execution Node at  " + node.hostname + ":" + node.port + " Error: " + e.message);
      //return if all requets processed
      numOfNodes = numOfNodes - 1;
      if (numOfNodes === 0) {
        console.log("DispRes");
        dispResult();
      }
    });
    req_checkNodeConn.end();
  } //checkNodeConnection ends

  //Check connection of all nodes
  for (i = 0; i < nodes_data.Nodes.length; i = i + 1) {
    console.log(numOfNodes);
    checkNodeConn(nodes_data.Nodes[i]);
  }
});

app.post("/submit", function (req, res) {
  console.log("submit post request received");
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
  console.log("sendScores post request received");
  var submission_json = req.body.submission_details,
    node_json = req.body.node_details,
    body,
    https_job_options,
    request,
    assigned_node,
    assigned_hostname,
    assigned_port,
    array,
    q,
    q1,
    total_score,
    code_download_flag,
    table_name,
    exec_command;
  node_queue.push(node_json);
  res.send(true);
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

  array = submission_json.marks;
  if (submission_json.status ===  1 || submission_json.status === 2) {
    total_score = 0;
    for (i = 0; i < array.length; i = i + 1) {
      total_score = total_score + parseInt(array[i], 10);
    }
    total_score = total_score - parseInt(submission_json.penalty, 10);
    if (total_score < 0) {
      total_score = 0;
    }

    code_download_flag = 0;
    table_name = "l" + submission_json.Lab_No;
    q = "SELECT * FROM " + table_name + " WHERE id_no = \"" + submission_json.id_no + "\"";
    connection.query(q, function (err, rows, fields) {
      if (err) {
        console.log(err);
      }
      if (rows === undefined || rows.length === 0) {
        q1 = "INSERT INTO " + table_name + " VALUES (\"" + submission_json.id_no + "\", " + total_score + ",\"" + submission_json.time + "\")";
        connection.query(q1, function (err, rows, fields) {
          console.log(err);
        });
        code_download_flag = 1;
      } else {
        if (rows[0].score < total_score) {
          q1 = "UPDATE " + table_name + " SET score=" + total_score + ", time=\"" + submission_json.time + "\" WHERE id_no=\"" + submission_json.id_no + "\"";
          connection.query(q1, function (err, rows, fields) {
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
    });
  }
});

app.post("/addNode", function (req, res) {
  console.log("addNode post request received");
  res.send(true);
  // Check if the Execution node is already accounted for in the queue,return if it is.
  for (i = 0; i < node_queue.length; i = i + 1) {
    if (node_queue[i].hostname === req.body.hostname && node_queue[i].port === req.body.port) {
      return;
    }
  }

  console.log(req.body);
  node_queue.push(req.body);
  console.log("Added " + req.body.hostname + ":" + req.body.port + " to queue");
  if (job_queue.length !== 0) {
    var assigned_node = node_queue.pop(),
      assigned_hostname = assigned_node.hostname,
      assigned_port = assigned_node.port,
      body = JSON.stringify(job_queue.pop()),
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

  }
});

try {
  connection = mysql.createConnection(nodes_data.database);
  connection.connect();
} catch (e) {
  console.log(e);
}

function checkNodeConn(node) {
  var https_checkConn = {
    hostname : node.hostname,
    port : node.port,
    path : "/connectionCheck",
    key : fs.readFileSync("./ssl/key.pem"),
    cert: fs.readFileSync("./ssl/cert.pem"),
    rejectUnauthorized: false
  },
    checkConnRequest = https.request(https_checkConn, function (res) {
      var bodyChunks = [];
      res.on("data", function (chunk) {
        bodyChunks.push(chunk);
      }).on("end", function () {
        var body = Buffer.concat(bodyChunks);
        if (body.toString() === "true") {
          console.log("Added " + node.hostname + ":" + node.port + " to queue");
          node_queue.push(node);
        }
      });
    });

  checkConnRequest.on("error", function (err) {
    console.log("Error connecting to " + node.hostname + ":" + node.port + " " + err);
  });

  checkConnRequest.end();
}

for (i = 0; i < nodes_data.Nodes.length; i = i + 1) {
  checkNodeConn(nodes_data.Nodes[i]);
}

setInterval(function () {
  connection.query("SELECT 1", function (err, rows, fields) {
    if (err) {
      console.log("Error connecting to the database");
    } else {
      console.log("keep alive query");
    }
  });
}, 10000);

module.exports = {
  app: app,
  server: server,
  node_queue: node_queue,
  job_queue: job_queue
};
