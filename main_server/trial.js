var https = require('https')
var fs = require('fs');
var express = require('express');
var options =
{
  key : fs.readFileSync("key.pem"),
  cert: fs.readFileSync("cert.pem"),
  rejectUnauthorized:false,
}
var app = require('express')();
var server = https.createServer(options,app)
var to = require('socket.io')(server);
var fs = require('fs')
//console.log(fs.readFileSync("cert.pem"));

app.use(express.static(__dirname + '/public'));

server.listen(9000);


app.get("/",function(req,res)
{
	console.log("HELLO WORLD");
  res.send("Hello World")
  // res.send("./public/index.html")
})
