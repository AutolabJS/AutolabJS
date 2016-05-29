var https = require('https')
var fs = require('fs');
var options2 = {
    hostname: 'localhost',
    port:8081,
    path: '/submit',
    method: 'POST',
    cert: fs.readFileSync('cert.pem'),
    key: fs.readFileSync('key.pem'),
    rejectUnauthorized:false,
    headers: {
        "Content-Type": "application/json",
      }
};
console.log("started");
req =https.request(options2,function(res)
{
  res.on('data',function(chunk)
  {
  	console.log(chunk.toString('utf-8'))
  })
});

req.on('error',function(err)
{
	console.log(err);
})
// req.end(JSON.stringify({submission_details:{id:"Tejas"},
//   node_details: { hostname: 'localhost', port: '8082' }}));

var obj={
  id_no : "IDNO",
  lab_no : "lab1",
  commit: "Commit",
  time : new Date().toString(),
  status : "Status",
  penalty: 10
}

req.end(JSON.stringify(obj));
