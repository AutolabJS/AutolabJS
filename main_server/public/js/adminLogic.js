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
        event.preventDefault();
        console.log("Clicked")
        $('.revaluation:checked').each(function()
        {
          socket.emit('revaluate',{
            labname: $(this).val()
          })

          console.log($(this).val())
        })

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


          $('<div class="l4 m4 s4" style="float:left;width:33%">'+
             '<input type="checkbox" id="'+ data.Labs[i] +'" class = "filled-in revaluation" value="'+ data.Labs[i] +'"> '+
              '<label for ="'+ data.Labs[i] +'">'+ data.Labs[i] +'</label></div>').insertBefore('#dummy-modal')
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
        console.log(data)
      })


      socket.on('update_score',function(lab)
      {
        $('#updated_score_div').show();
        $('<a href="/revaluation/download/'+lab+'"  class="collection-item">'+lab+'</a>').insertBefore('#dummy_score')
      })

      socket.on('update_core_timeout',function(lab)
      {
        alert("Sorry the revaluation request for " + lab + " timed out! Try again later");
      })


      
  });
