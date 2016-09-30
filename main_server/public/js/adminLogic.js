$(document).ready(function() {
    $('.modal-trigger').leanModal();
    $('#logout-navbar').hide();

      $('.collapsible').collapsible({
        accordion : false // A setting that changes the collapsible behavior to expandable instead of the default accordion style
      });

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
    			

          $('<div class="collection-item" style="float:left;width:33%">'+
             '<input type="checkbox" id="'+ data.Labs[i] +'" class = "filled-in revaluation" value="'+ data.Labs[i] +'"> '+
              '<label for ="'+ data.Labs[i] +'">'+ data.Labs[i] +'</label></div>').insertBefore('#dummy-modal')
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