var request = require('request');
var fs = require('fs');
var path = require('path');
var ssl = {
	key: fs.readFileSync(path.join(__dirname , '..', '/ssl/key.pem')),
	cert: fs.readFileSync(path.join(__dirname , '..', '/ssl/cert.pem'))
}

module.exports = function(hostname,rootId,password)
{
	function getPrivateToken(callback)
	{
		request.post({
			url:'https://'+hostname+'/api/v3/session',
			form:{login:rootId, password:password},
			cert:ssl.cert,
			key:ssl.key,
			rejectUnauthorized:false },
			function(err,response,body)
			{
				body = JSON.parse(body);

				if(err!=null || body["private_token"]==undefined) 
					return callback(new Error("Admin Login failed!Please try again"));

				return callback(null,body["private_token"]);
			})
	}

	function getUserId(private_token,username,callbck)
	{
		request.get({url:"https://"+hostname + "/api/v3/users?username="+username + "&private_token="+private_token,
			cert:ssl.cert,
			key:ssl.key,
			rejectUnauthorized:false },
			function(err,response,body)
			{
				body = JSON.parse(body);
				if(err || body["id"]==undefined)
					return callback(new Error("failed to get Userid"));

				return callback(null,body["id"]);
			})
	}

	function getProjectId(private_token,username,projectName,callback)
	{
		console.log("https://"+hostname + "/api/v3/projects/"+username + "%2F" + projectName + "/?private_token="+private_token)
		request.get({url:"https://"+hostname + "/api/v3/projects/"+username + "%2F" + projectName + "/?private_token="+private_token,
			cert:ssl.cert,
			key:ssl.key,
			rejectUnauthorized:false  },
			function(err,response,body)
			{

				body = JSON.parse(body);
				if(err  || body["id"]==undefined) 
					return callback(new Error("Failed to get ProjectId"));

				return callback(null,body["id"]);
			})
	}

	function getCommits(private_token,projectId,callback)
	{
		request.get({url:"https://"+hostname + "/api/v3/projects/" + projectId + "/repository/commits?private_token="+private_token,
			cert:ssl.cert,
			key:ssl.key,
			rejectUnauthorized:false  },
			function(err,response,body)
			{
				body = JSON.parse(body);
				if(err) 
					return callback(new Error("Failed to get commits"));

				return callback(null,body);
			})
	}

	return {
		getPrivateToken:getPrivateToken,
		getUserId:getUserId,
		getProjectId:getProjectId,
		getCommits:getCommits
	}
}