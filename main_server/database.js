var mysql = require('mysql');


var connection = mysql.createConnection(
  require('/etc/main_server/conf.json').database
);

connection.connect();

if(process.env.mode != "TESTING")
{
	setInterval(function () {
	  connection.query('SELECT 1' ,function(err, rows, fields) {
	    console.log("keep alive query");
	  });
	}, 10000);
}

module.exports = connection;