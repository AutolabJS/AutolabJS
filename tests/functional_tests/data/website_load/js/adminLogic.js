$(document).ready(function() {
    $('.modal-trigger').leanModal();
    $('#logout-navbar').hide();
    $('#takeToConfig').hide();
    $('#reval_button').hide();
    $('#reval_list').hide();
    $('#updated_score_div').hide();
      $('.collapsible').collapsible({
        accordion : false // A setting that changes the collapsible behavior to expandable instead of the default accordion style
      });





    $('#takeToConfig').click(function(event)
    {
      event.preventDefault();
      window.location = window.location.origin + '/config'
    })

      $('#revalSubmit').click(function(event)
      {
        reval_labs =[];
        event.preventDefault();
        console.log("Clicked")
        $('.revaluation:checked').each(function()
        {

          var id = $(this).attr('id');
          var s_date = $('#'+id+'_start').val().split(' ');
          var e_date = $('#'+id+'_end').val().split(' ');
          if(s_date.length!=2 || e_date.length != 2) alert("Enter the date in the following format\n DD/MM/YYYY HH:MM")
          reval_labs.push({
            labname: $(this).val(),
            start_date:s_date[0].split('/')[0],
            start_month:s_date[0].split('/')[1],
            start_year:s_date[0].split('/')[2],
            start_hour:s_date[1].split(':')[0],
            start_minute:s_date[1].split(':')[1],
            end_date:e_date[0].split('/')[0],
            end_month:e_date[0].split('/')[1],
            end_year:e_date[0].split('/')[2],
            end_hour:e_date[1].split(':')[0],
            end_minute:e_date[1].split(':')[1],
          })

        })
        socket.emit('revaluate',reval_labs)
        $('#reval_list').hide();
      })

    	var socket = io.connect();

    	$('#submit').click(function(event)
    	{
    		event.preventDefault();
        $('#dropdown2').hide();
    		socket.emit('authorize',{key:$('#APIKey').val()});
    		socket.emit('send_reval_data',{});
    	})

    	socket.on('reval',function(data)
    	{

        //Get the already existing labs as returned by the server

        var existing_boxes = [];
        var temp = document.getElementsByTagName('input');
        for(var i in temp)
        {
          if(temp[i].type == 'checkbox') existing_boxes.push(temp[i].value);
        }

        console.log(existing_boxes)
    		console.log(data.Labs)

    		for(var i = 0;i<data.Labs.length;i++)
    		{
          if(existing_boxes.indexOf(data.Labs[i])!=-1)
                continue; //Dont create a new checkbox if there is already one with the same lab name


          $('<div class="l4 m4 s4 " style="float:left;width:33%">'+
             '<input type="checkbox" id="'+ data.Labs[i] +'" class = "filled-in revaluation" value="'+ data.Labs[i] +'">'+
              '<label for ="'+ data.Labs[i] +'">'+ data.Labs[i] +'</label> <br/>'+
              '<input type="text" style="width:50%"  id="'+data.Labs[i]+'_start">'+
              '<label for ="'+ data.Labs[i] +'_start"> Start time</label><br/>'+
              '<input type="text" style="width:50%" id="'+data.Labs[i]+'_end">'+
              '<label for ="'+ data.Labs[i] +'_end"> End time</label><br/>'+
              '</div>').insertBefore('#dummy-modal');
    		}
    	})

      socket.on('login_success',function(data)
      {
        console.log("Success")
          $('#login_card').hide();
          $('#logout-navbar').show();
          $('#takeToConfig').show();
          $('#reval_button').show();
         // socket.emit('send_reval_data',{});
      })



      $('#logout').click(function(event)
      {
        event.preventDefault();
        socket.emit('logout');
        location.reload();
      })


      $('#reval_button').click(function(event)
      {
        event.preventDefault();
        console.log('toggle')
        $('#reval_list').toggle();
      })

      socket.on('course details',function(data)
      {
        $('#logo_container').html(data["course number"] + ' : Admin Portal');
        console.log(data);
      })


      socket.on('update_score',function(lab)
      {
        console.log(lab)
        $('#updated_score_div').show();
        $('<a href="/revaluation/download/'+lab+'"  class="collection-item">'+lab+'</a>').insertBefore('#dummy_score')
      })

      socket.on('update_score_timeout',function(lab)
      {
        alert("Sorry the revaluation request for " + lab + " timed out! Try again later");
      })



  });
