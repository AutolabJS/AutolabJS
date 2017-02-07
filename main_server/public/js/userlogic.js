var download_marks=[];
var current_lab = '';
var id_no='';

function download_csv() {
  var blob = new Blob([download_marks], {
    type: "text/plain;charset=utf-8;",
  });
  saveAs(blob, current_lab+".csv");
};

// http://stackoverflow.com/a/20618517
function startTimer(duration, display) {
  var timer = duration, minutes, seconds;
  var id = setInterval(function () {
    minutes = parseInt(timer / 60, 10)
    seconds = parseInt(timer % 60, 10);

    minutes = minutes < 10 ? "0" + minutes : minutes;
    seconds = seconds < 10 ? "0" + seconds : seconds;

    display.text(minutes + ":" + seconds);
    if (--timer < 0) {
      display.text("Time elapsed");
      clearInterval(id);
    }

  }, 1000);
}

$(document).ready(function() {
  $(".dropdown-button").dropdown();
  $("#labs").hide();
  $("#submission").hide();
  $("#evaluating").hide();
  $("#marks").hide();
  $("#scorecard").hide();
  $("#invalidLab").hide();

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
      lab_block = "<div class=\"col s4 m4\"> <div class=\"card #ffffff white\"> <div class=\"card-content black-text\"> <span class=\"card-title\">"+data[i].Lab_No.Lab_No+"</span> <ul><li>Starts at\t"+data[i].Lab_No.start_hour+":"+data[i].Lab_No.start_minute+" on "+data[i].Lab_No.start_date+"-"+data[i].Lab_No.start_month+"-"+data[i].Lab_No.start_year;
      lab_block=lab_block + "</li><li>Ends at \t"+data[i].Lab_No.end_hour+":"+data[i].Lab_No.end_minute+" on "+data[i].Lab_No.end_date+"-"+data[i].Lab_No.end_month+"-"+data[i].Lab_No.end_year+"</li><li>Late Deadline at \t"+data[i].Lab_No.hard_hour+":"+data[i].Lab_No.hard_minute+" on "+data[i].Lab_No.hard_date+"-"+data[i].Lab_No.hard_month+"-"+data[i].Lab_No.hard_year+"</li><li>Late Penalty: \t"+data[i].Lab_No.penalty+" mark(s) </li><li>Remaining Time: <span class=\"time\">" + data[i].delta + "</span></li></ul> </div> <div class=\"card-action\"> <a id=\"subl"+data[i].Lab_No.Lab_No+"\" href=\"#\">Submit</a> <a id=\"scol"+data[i].Lab_No.Lab_No+"\" href=\"#\">Scoreboard</a></div> </div> </div>"
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

    $('.time').each(function(idx) {
      startTimer($(this).text(), $(this));
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
        entry="<a href=\"\" onClick=\"download_csv(); return false;\">Download as CSV</a>";
        $("#scorecard #download").append(entry);
        download_marks=[];
        for(i=0;i<response.length;i++)
        {
          entry ="<tr> <td>"+(i+1)+"</td><td>"+response[i].id_no+"</td> <td>"+response[i].score+"</td> </tr>";
          $("#scorecard tbody").append(entry);
          download_marks=download_marks+response[i].id_no+", "+response[i].score+"\n"
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
    if(data.status==0)
    {
      $("#marks").append("<p class=\"collection item\"><h6><b>Warning:</b> This lab is not active. The result of this evaluation is not added to the scoreboard.<h6>");
    }
  });
});
