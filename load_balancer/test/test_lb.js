process.env.mode = "TESTING"
var app = require('../load_balancer.js').app;
var server = require('../load_balancer.js').server;
var node_queue = require('../load_balancer.js').node_queue;
var job_queue = require('../load_balancer.js').job_queue;
var nock = require('nock')
var chai = require('chai');
chai.use(require('chai-http'));
var io = require('socket.io-client')
var fs = require('fs')
var http = require('http');
var https = require('https');
var should = chai.should();
const path = require('path');
var request = require('request');

describe("Testing Load Balancer",function()
{
  before(function(done)
  {
      server.listen(8081);
      console.log(process.cwd());
      server_node = require(path.join(__dirname + '/mock_node.js'));
      process.chdir("../main_server");
      server_main = require(path.join(process.cwd() + '/main_server.js')).server;
      server_main.listen(9000);
      done();
  })

  it('Check submission',function(done)
  {
    var socket = io.connect('https://localhost:9000');
    
    socket.on('scores',function(data)
    {
      console.log(data);
      done(); 
    });
    
    socket.on('connect',function()
    {
      var options = {
      uri: 'https://localhost:8081/submit',
      method: 'POST',
      json: {socket:socket.io.engine.id},
      key : fs.readFileSync('./ssl/key.pem'),
        cert: fs.readFileSync('./ssl/cert.pem'),
        rejectUnauthorized:false,
      };

      var req = request(options,function(err,res,body)
      {
        console.log(err);
        console.log(body);
      })
    })
    
		
  }).timeout(10000)


  after(function(done)
  {
      server_main.close();
      done();
  })
})
