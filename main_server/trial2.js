var https = require('https')
var fs = require('fs');
var options2 = {
    hostname: 'localhost',
    port:9000,
    path: '/',
    method: 'GET',
    cert: fs.readFileSync('cert.pem'),
    key: fs.readFileSync('key.pem'),
    rejectUnauthorized:false,
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

req.end();
