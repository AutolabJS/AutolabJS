$(document).ready(function() {

  $("#labs").hide();
  $("#submission").hide();
  $("#evaluating").hide();
  $("#marks").hide();
  $("#scorecard").hide();
  $("#invalidLab").hide();

  var current_lab = '';
  var id_no='';

  var socket = io.connect();

  socket.on('course details',function(data)
{
  $('#logo-container').text(data['course number'] + ": " + data['name'])
  list_start = '<li><a class="grey-text text-lighten-3" target="_blank" href="#!">'
  list_end ='</a></li>'
  var list = ""
  list+= list_start + data['instructor in charge'] + "  (Instructor In-charge)" + list_end
  for(var ins in data['other instructors']) list += list_start + data['other instructors'][ins] + list_end
  $('#instructors').append(list)
})
  socket.on('labs_status', function(data) {
    $("#loadingDiv").hide();
    $("#submission").hide();
    $("#evaluating").hide();
    $("#marks").hide();
    $("#scorecard").hide();
    $("#invalidLab").hide();
    $("#inactiveLabContainer .row").empty();
    $("#activeLabContainer .row").empty();
    for(var i=0;i<data.length;i++)
    {
      lab_block = "<div class=\"col s4 m4\"> <div class=\"card #ffffff white\"> <div class=\"card-content black-text\"> <span class=\"card-title\">"+data[i].Lab_No.Lab_No+"</span> <ul><li>Date: \t"+data[i].Lab_No.start_date+"-"+data[i].Lab_No.start_month+"-"+data[i].Lab_No.start_year+"</li><li>Start Time: \t"+data[i].Lab_No.start_hour+":"+data[i].Lab_No.start_minute;
      lab_block=lab_block + "</li> <li>End Time: \t"+data[i].Lab_No.end_hour+":"+data[i].Lab_No.end_minute+"</li> <li>Hard Deadline:\t"+data[i].Lab_No.hard_hour+":"+data[i].Lab_No.hard_minute+"</li><li>Late Penalty: \t"+data[i].Lab_No.penalty+" mark(s) </li></ul> </div> <div class=\"card-action\"> <a id=\"subl"+data[i].Lab_No.Lab_No+"\" href=\"#\">Submit</a> <a id=\"scol"+data[i].Lab_No.Lab_No+"\" href=\"#\">Scoreboard</a></div> </div> </div>";
      if(data[i].status==0)
      {
        $("#inactiveLabContainer .collection").empty();
        $("#inactiveLabContainer .row").append(lab_block);
      }
      else {
        $("#activeLabContainer .collection").empty();
        $("#activeLabContainer .row").append(lab_block);
      }
    }
    $("#labs").show();

    $('[id^=subl]').on('click', function(e) {
      e.preventDefault();
      current_lab=$(this).attr('id').substring(4);
      $('#labs').hide();
      $('#submission').show();
    });

    $('[id^=scol]').on('click', function(e) {
      e.preventDefault();
      current_lab=$(this).attr('id').substring(4);
      $('#labs').hide();
      $('#loadingDiv').show();
      request = $.ajax({
        url: "/scoreboard/"+current_lab,
        type: "get",
      });
      request.done(function (response, textStatus, jqXHR){
        $('#loadingDiv').hide();
        $("#scorecard").show();
        for(i=0;i<response.length;i++)
        {
          entry ="<tr> <td>"+(i+1)+"</td><td>"+response[i].id_no+"</td> <td>"+response[i].score+"</td> </tr>";
          $("#scorecard tbody").append(entry);
        }
      });
    });
  });

  $('#submitButton').on('click', function(e) {
   e.preventDefault();
   $("#submission").hide();
   $("#evaluating").show();
   id_no=$('#nameField').val();
   commit_hash=$('#commitHash').val();
   socket.emit('submission', [id_no, current_lab, commit_hash]);
   commit_hash="";
 });

  socket.on('invalid', function(data) {
    $("#evaluating").hide();
    $("#invalidLab").show();
  });

  socket.on('scores', function(data) {
    $("#evaluating").hide();
    $("#marks").show();
    total_score=0;
    for(i=0;i<data.marks.length;i++)
    {
      total_score=total_score+ parseInt(data.marks[i]);
      status = "Accepted";
      if(data.comment[i]==0) {
        status="Wrong Answer"
      }
      if(data.comment[i]==1 && data.marks[i]==0) {
        status="Compilation Error"
      }
      if(data.comment[i]==2 && data.marks[i]==0) {
        status="Timeout"
      }
      entry ="<tr> <td>"+(i+1)+"</td><td>"+status+"</td> <td>"+data.marks[i]+"</td> </tr>";
      $("#marks tbody").append(entry);
    }
    total_score = total_score - parseInt(data.penalty);
    if(total_score < 0)
    {
      total_score = 0;
    }
    if(data.status!=0)
    {
      $("#marks").append("<h5 class = \"header light\">Penalty = "+data.penalty+"</h5>");
    }
    $("#marks").append("<h4 class = \"header light\">Total Score = "+total_score+"</h4>");
  });
});
