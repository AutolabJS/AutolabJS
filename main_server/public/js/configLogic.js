$(document).ready(function() {
  $('.modal-trigger').leanModal();
  $('#logout-navbar').hide();


  $(document).ready(function(){
    $('#dropdown2').dropdown({
      belowOrigin:true,
      constrain_width: false, 
      hover: false,
      gutter:0,
      alignment:'left', 
    })


    $('#dropdown2').click(function(event)
    {
      event.preventDefault();

      return false;
    })
  });
  function changeName()
  {
  	var lab_id = $(this).attr('id')
  		
  		
  		$('div#'+lab_id).html('<i class="material-icons">mode_edit</i>' + $('form#'+lab_id+' input#'+lab_id).val())
  		
  }
  	



  	number_of_instructors =0;
  	$('#add_instructor').click(function(event)
  	{
  		event.preventDefault();
  		$('<div class="row">'+
	        '<div class="input-field col s12">'+
	          '<input id="instructor '+ (++number_of_instructors) +'" type="text" class="validate">'+
	          '<label for="instructors">Instructor '+(number_of_instructors) + '</label>'+
	        '</div>'+
	      '</div>').insertBefore('#add_instructor');

  		console.log(number_of_instructors);
  	})

  	number_of_labs =0;
  	$('#add_lab').click(function(event)
  	{
  		event.preventDefault();

  		$('<li class = "row" id = "lab'+(++number_of_labs) +'">'+
     '<div class="collapsible-header"  id = "lab'+(number_of_labs)+'"><i class="material-icons">mode_edit</i>Lab'+(number_of_labs)+'</div>'+
     '<div class="collapsible-body">'+
	   '<form class="col s12" id="lab'+(number_of_labs) +'">'+
	      '<div class="row">'+
	        '<div class="input-field col s12">'+
	          '<input  type="text" class="validate listen" id="lab'+(number_of_labs)+'"">'+
	          '<label for="name">Lab name</label>'+
	        '</div>'+
	        
	        '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="start_date" >'+
	        		'<label for = "start_date"> Start Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	       
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="start_time" >'+
	        	'<label for = "start_time"> Start Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+
	        '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="end_date" >'+
	        		'<label for = "end_date"> End Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	        
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="end_time" >'+
	        		'<label for = "end_time"> End Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+
	         '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="hard_date" >'+
	        		'<label for = "hard_date"> Hard Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	       
	        	'<div class="input-field col s6 m6 l6 ">'+
	        		'<input type="text" class="validate"  id ="hard_time" >'+
	        		'<label for = "hard_time"> Hard Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+

	         '<div class="row">'+
	        	'<div class="input-field col s12 ">'+
	        		'<input type="text" class="validate"  id ="penalty" >'+
	        		'<label for = "penalty"> Penalty </label>'+
	        	'</div>'+
	        '</div>'+
	     
	    '</form>'+
	    '</div>'+
	   '</li><br/>').keyup(changeName).insertBefore('#add_lab');
  	})

  	function getDate(date,month,year)
  	{
  		return String(date) + '/' + String(month)+ '/' + String(year);
  	}
  	function getTime(hour,minutes)
  	{
  		return String(hour) + ':' + String(minutes);
  	}

  	function addLab(lab)
  	{
  		$('<li class = "row" id = "lab'+(++number_of_labs) +'">'+
     '<div class="collapsible-header " id = "lab'+(number_of_labs)+'"><i class="material-icons">mode_edit</i>'+lab["Lab_No"]+'</div>'+
     '<div class="collapsible-body">'+
	   '<form class="col s12" id="lab'+(number_of_labs) +'">'+
	      '<div class="row">'+
	        '<div class="input-field col s12">'+
	          '<input id="name" type="text" class="validate listen" id="lab_name" value = "'+lab["Lab_No"]+'">'+
	          '<label for="name">Lab name</label>'+
	        '</div>'+
	        
	        '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="start_date" value="'+getDate(lab.start_date,lab.start_month,lab.start_year)+'">'+
	        		'<label for = "start_date"> Start Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	       
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="start_time" value="'+getTime(lab.start_hour,lab.start_minute)+'">'+
	        	'<label for = "start_time"> Start Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+
	        '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="end_date" value="'+getDate(lab.end_date,lab.end_month,lab.end_year)+'">'+
	        		'<label for = "end_date"> End Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	        
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="end_time" value="'+getTime(lab.end_hour,lab.end_minute)+'">'+
	        		'<label for = "end_time"> End Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+
	         '<div class="row">'+
	        	'<div class="input-field col s6 m6 l6">'+
	        		'<input type="text" class="validate"  id ="hard_date" value="'+getDate(lab.hard_date,lab.hard_month,lab.hard_year)+'"">'+
	        		'<label for = "hard_date"> Hard Date (DD/MM/YYYY) </label>'+
	        	'</div>'+
	       
	        	'<div class="input-field col s6 m6 l6 ">'+
	        		'<input type="text" class="validate"  id ="hard_time"value="'+getTime(lab.hard_hour,lab.hard_minute)+'" >'+
	        		'<label for = "hard_time"> Hard Time (HH:MM) 24-hour format </label>'+
	        	'</div>'+
	        '</div>'+

	         '<div class="row">'+
	        	'<div class="input-field col s12 ">'+
	        		'<input type="text" class="validate"  id ="penalty" value="'+lab.penalty+'" >'+
	        		'<label for = "penalty"> Penalty </label>'+
	        	'</div>'+
	        '</div>'+
	     
	    '</form>'+
	    '</div>'+
	   '</li><br/>').keyup(changeName).insertBefore('#add_lab');
  	}


  	function addCourseDetails(course)
  	{
  		$('#name').val(course.name);
  		$('#number').val(course["course number"]);
  		$('#ic').val(course["instructor in charge"]);

  		for(var i =0;i<course["other instructors"].length;i++)
  		{
  			$('<div class="row">'+
	        '<div class="input-field col s12">'+
	          '<input id="instructors" type="text" class="validate" value="'+course["other instructors"][i]+'">'+
	          '<label for="instructors">Instructor '+(++number_of_instructors) + '</label>'+
	        '</div>'+
	      '</div>').insertBefore('#add_instructor');
  		}
  	}


  	var socket = io.connect();
  	
  	$('#save').click(function(event)
  	{
  		event.preventDefault();
  		var course={
  			name:$('#name').val(),
  			"course number":$('#number').val(),
  			"instructor in charge":$('#ic').val(),
  			"other instructors" :[],
  		}


  		for(var  i=1;i<=number_of_instructors;i++) 
  		{
  			course['other instructors'].push( $('#instructor '+i).val() );
  		}

  		var labs=[]

  		for(var i=1;i<=number_of_labs;i++)
  		{


  			var new_lab ={
  				"Lab_No":$('form#lab'+ i + ' input#lab' + i).val(),
  				start_date:$('form#lab'+ i + ' input#start_date').val().split('/')[0],
  				start_month:$('form#lab'+ i + ' input#start_date').val().split('/')[1],
  				start_year:$('form#lab'+ i + ' input#start_date').val().split('/')[2],
  				start_hour: $('form#lab'+ i + ' input#start_time').val().split(':')[0],
  				start_minute:$('form#lab'+ i + ' input#start_time').val().split(':')[1],
  				end_date:$('form#lab'+ i + ' input#end_date').val().split('/')[0],
  				end_month:$('form#lab'+ i + ' input#end_date').val().split('/')[1],
  				end_year:$('form#lab'+ i + ' input#end_date').val().split('/')[2],
  				end_hour:$('form#lab'+ i + ' input#end_time').val().split(':')[0],
  				end_minute:$('form#lab'+ i + ' input#end_time').val().split(':')[1],
  				hard_date:$('form#lab'+ i + ' input#hard_date').val().split('/')[0],
  				hard_month:$('form#lab'+ i + ' input#hard_date').val().split('/')[1],
  				hard_year:$('form#lab'+ i + ' input#hard_date').val().split('/')[2],
  				hard_hour:$('form#lab'+ i + ' input#hard_time').val().split(':')[0],
  				hard_minute:$('form#lab'+ i + ' input#hard_time').val().split(':')[1],
  				penalty:$('form#lab'+ i + ' input#penalty').val(),
  			}

  			labs.push(new_lab);

  		}

  		socket.emit('save',{
  			course:course,
  			labs:labs,
  		});

  	})

  	

  	socket.on('lab_data',function(data)
  	{
  		
  		var courses = data.course;
  		var lab = data.lab.Labs;
  		addCourseDetails(courses);

      var existing_labs =[];
      
  		for(var i=0;i<lab.length;i++)
  		{
  			console.log(lab[i].start_hour)
  			addLab(lab[i]);
  		}
  	})


    socket.on('login_success',function(data)
    {
      console.log("Success")
        $('#login-navbar').hide();
        $('#logout-navbar').show();
    })



    $('#logout').click(function(event)
    {
      event.preventDefault();
      socket.emit('logout');
      location.reload();
    })

  });