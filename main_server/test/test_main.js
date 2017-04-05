process.env.mode = "TESTING"
// var sinon = require('sinon');
var main_server = require('../main_server.js');
var app = main_server.app;
var server = main_server.server;
// var connection = main_server.connection;



var chai = require('chai');
chai.use(require('chai-http'));
var io = require('socket.io-client');
var fs = require('fs')
var http = require('http');
var https = require('https');
var should = chai.should();


describe("Testing main server",function()
{
	

	beforeEach(function(done)
	{
		server.listen(9000);
		done();
	})
	it("Home page Status code",function(done)
	{
		var request = https.request(
		{
			path:'/',
			port:9000,
			method:'GET',
			key : fs.readFileSync('./ssl/key.pem'),
		    cert: fs.readFileSync('./ssl/cert.pem'),
		    rejectUnauthorized:false,
		},function(res)
		{

			res.statusCode.should.equal(200);
			done();

		})

		request.on('error',function(err)
		{
			console.log(err);
		})
		request.end();



	});

	it("HTTP to HTTPS Redirection",function(done)
	{
		var request = http.request(
		{
			path:'/',
			port:9000,
			method:'GET',
		},function(res)
		{

			res.statusCode.should.equal(302);
			res.headers.location.substring(0,5).should.equal("https");

			done();
		})

		request.on('error',function(err)
		{
			console.log(err);
		})
		request.end();


	})

	it('Admin page status code',function(done)
	{
		var request = https.request(
		{
			path:'/admin',
			port:9000,
			method:'GET',
			key : fs.readFileSync('./ssl/key.pem'),
		    cert: fs.readFileSync('./ssl/cert.pem'),
		    rejectUnauthorized:false,
		},function(res)
		{

			res.statusCode.should.equal(200);
			done();
		})

		request.on('error',function(err)
		{
			console.log(err);
		})
		request.end();
	})

	it('Redirection from config to admin page if not loged in',function(done)
	{
		var request = https.request(
		{
			path:'/config',
			port:9000,
			method:'GET',
			key : fs.readFileSync('./ssl/key.pem'),
		    cert: fs.readFileSync('./ssl/cert.pem'),
		    rejectUnauthorized:false,
		},function(res)
		{

			res.statusCode.should.equal(302);
			res.headers.location.should.equal('/admin');
			done();
		})

		request.on('error',function(err)
		{
			console.log(err);
		})
		request.end();
	})

	it('Getting the status for all existing labs',function(done)
	{
		var socket = io.connect('https://localhost:9000');
		socket.on('labs_status',function(data)
		{
			done();
			socket.destroy();

		})

		//done(new Error('failed'));
	})

	it('Getting the course details',function(done)
	{
		var socket = io.connect('https://localhost:9000');

		socket.on('course details',function(data)
		{
			done();
			socket.destroy();

		})

		//done(new Error("failed"));
	})

	it('Getting a scorecard for a particular lab',function(done)
	{
		var request = https.request({
			path:'/scoreboard/lab2',
			port:9000,
			method:'GET',
			key : fs.readFileSync('./ssl/key.pem'),
		    cert: fs.readFileSync('./ssl/cert.pem'),
		    rejectUnauthorized:false,
		},function(res)
		{
			res.statusCode.should.equals(200);
			done();

		})

		request.on('error',function(err)
		{
			console.log(err);
		})
		request.end();


	});


	it("Check login with the wrong key",function(done)
	{
			var socket = io.connect('https://localhost:9000' );

			// Checking whether the admin page loads before login.
			var request = https.request(
			{
				path:'/admin',
				port:9000,
				method:'GET',
				key : fs.readFileSync('./ssl/key.pem'),
					cert: fs.readFileSync('./ssl/cert.pem'),
					rejectUnauthorized:false,
			},function(res)
			{
				res.statusCode.should.equal(200);
				//After page load, enter the wrong password.

				socket.emit('authorize',{
					key:'This is a Wrong key'
				})
			})

			request.end();

			socket.on('successful login',function(data)
			{
				done(new Error('fail'));
				socket.destroy();
			})

			socket.on('login failed',function(data)
			{
				done();
				socket.destroy();
			})
	})

	it("Check login with the right key",function(done)
	{
		var socket = io.connect('https://localhost:9000');

		// Checking whether the admin page loads before login.
		var request = https.request(
		{
			path:'/admin',
			port:9000,
			method:'GET',
			key : fs.readFileSync('./ssl/key.pem'),
		    cert: fs.readFileSync('./ssl/cert.pem'),
		    rejectUnauthorized:false,
		},function(res)
		{
			res.statusCode.should.equal(200);
			//After page load, enter the wrong password.

			socket.emit('authorize',{
				key:'q'
			})
		})

		request.end();

		socket.on('successful login',function(data)
		{
				done();
		})

	})

	it('Check if the revaluation list is sent after login',function(done)
	{
			var socket = io.connect('https://localhost:9000');

			socket.emit('authorize',{key:'q'});
			socket.on('login failed',function(data)
			{
				done(new Error("Failed due to unsuccessful Login"));
			})

			socket.on('successful login',function(data)
			{

					socket.emit('send_reval_data');
			})

			socket.on("reval",function(data)
			{
				if(Object.keys(data).length >0) done();
				else done(new Error("Recieved an empty object with no labs for revaluation"));
			})
	})


	it("Check if new lab can be added",function(done)
	{
		var present_labs = require('../config/labs.json').Labs;
		var present_courses =  require('../config/courses.json');
		var new_lab = {
			"Lab_No":'test_lab',
			"start_date":"",
			"start_month":"",
			"start_year":"",
			"start_hour":"",
			"start_minute":"",
			"start_minute":"",
			"end_date":"",
			"end_month":"",
			"end_year":"",
			"end_hour":"",
			"end_minute":"",
			"hard_date":"",
			"hard_month":"",
			"hard_year":"",
			"hard_hour":"",
			"hard_minute":"",
			"penalty":"",
		}

		present_labs.push(new_lab);
		var socket = io.connect('https://localhost:9000');

		socket.emit('authorize',{key:'q'});

		socket.on('successful login',function()
		{

			socket.emit('save',
			{
				labs:present_labs,
				course:present_courses
			})
			socket.on('saved',done);
		})
	})

	it('Check deletion of a lab',function(done)
	{
		var socket = io.connect('https://localhost:9000');

		socket.emit('authorize',{key:'q'});

		socket.on('successful login',function()
		{

			socket.emit('delete lab','test_lab');
			socket.on('deleted',done);

		})
	})


	it('Check logout from the admin portal',function(done)
	{
		var socket = io.connect('https://localhost:9000');

		socket.emit('authorize',{key:'q'});

		socket.on('successful login',function()
		{
			socket.emit('logout')
			socket.on('logged out',function()
			{
				console.log("Logged");
				done();
			});
		})

	}).timeout(1000)

	afterEach(function(done)
	{
		server.close(done);
	})
})
