//= require jquery.min
//= require jquery_ujs
//= require jquery.ui.datepicker
//= require jquery.ui.slider
//= require jquery-ui-timepicker-addon
//= require jquery.event.hover-1.0
//= require jquery.countdown
//= require jquery.url
//= require hoverIntent
//= require superfish
//= require_self


// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//

function createCookie(name,value,days) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime()+(days*24*60*60*1000));
    var expires = "; expires="+date.toGMTString();
  }
  else var expires = "";
  document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') c = c.substring(1,c.length);
    if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
  }
  return null;
}

var expandspeed = 1;
var minduration = 250;
function toggle_height(id, displaytype) {
  if ($("#"+id).data("height")==undefined) {
    $("#"+id).data("height",$('#'+id).height());
    $("#"+id).data("state",0);
    var e = document.getElementById(id);
    e.style.height = "0px";
    e.style.display = ((typeof(displaytype)=="undefined")?"block":displaytype);
  }
  if ($("#"+id).data("state")==0) {
    $("#"+id).stop();
    $("#"+id).animate({'height':$("#"+id).prop("scrollHeight")},Math.max(($("#"+id).data("height")-$("#"+id).height())/expandspeed,minduration), function() { $("#"+id).height("auto"); });
    $("#"+id).data("state",1);
  }
  else {
    $("#"+id).stop();
    $("#"+id).animate({'height':0},Math.max($("#"+id).height()/expandspeed,minduration));
    $("#"+id).data("state",0);
  }
}

var duration = 250;
function shrink() {
  createCookie("expanded", "false", 31);
  $("#side").animate({width:'50px'}, duration);
  $('#main-menu').animate({'left':'50px'}, duration);
  $('#side-minify').html("&#9654;");
  $('#main').animate({'left':'50px'}, duration);
  $('#side-expanded').animate({'opacity':'0'},duration);
  $('#side-contracted').animate({'opacity':'1'}, duration);
}

function expand() {
  createCookie("expanded", "true", 31);
  $("#side").animate({width:'200px'}, duration);
  $('#main-menu').animate({'left':'200px'}, duration);
  $('#side-minify').html("&#9664;");
  $('#main').animate({'left':'200px'}, duration);
  $('#side-expanded').animate({'opacity':'1'},duration);
  $('#side-contracted').animate({'opacity':'0'}, duration);
}

$(document).ready(function() {
  var expanded = readCookie("expanded");
  if(expanded == "false") {
  	duration = 0;
  	shrink();
  	duration = 250;
  }
  $('#side-minify').click(function() {
    if($('#side').width() <= 100)
      expand();
    else
      shrink();
  });

  $("table.selectable > tbody > tr").click(function() {
    $(this).toggleClass("selected_row");
  });

  $("#left-menu").superfish({
    animation: {opacity:'show',height:'show'},
    speed: 'fast'
  });

  $("#right-menu").superfish({
    cssArrows: false,
    speed: 'fast'
  });

  $('#menu').css({'min-width':$('#nav').width()+$('#controls').width() + 'px'});

  $('.date-picker').blur(); // blur so that datetimepicker works properly in case it is already selected
  $('.date-picker').datetimepicker({ dateFormat: 'dd/mm/yy' });

  $(".submission_details").click(function() {
    console.log("abc");
    $(this).find(".submission_details_hider").slideDown();
  });
  $(".submission_details_hider").hide();

  $(".radio_input").click(function() {
    $(this).prevAll("input[type=radio]:first").prop("checked", true);
  });

  // on radio button, will select a certain div to display?
  //$("input[type=radio].select").change(function() {
  //  $("." + $(this).attr('name')).hide();
  //  $("." + $(this).attr('name') + "." + $(this).val()).show();
  //});
  $(".togglelink").click(function() {
    if (typeof $(this).data("toggle") === "undefined") return;
    $(this).parent().children("." + $(this).data("toggle"))
      .toggle()
      .prop('disabled', function(i, v) { return !v; });
    
  });

  function on_country_change() {
    if ($("#user_country_code option:selected").text() === "New Zealand") {
      $(".nzonly").show();
    } else {
      // reset jsdisplay for "Add new school"
      $(".jsdisplay").show().prop('disabled', false);
      $(".jsnodisplay").hide().prop('disabled', true);

      // set defaults for non-NZ users
      $("#user_school_id").val(''); // select no school
      $("#user_school_graduation_enabled_false").prop("checked", true); // select unspecified grad date

      $(".nzonly").hide();
    }
  }

  $(".jsdisplay").show().prop('disabled', false);
  $(".jsnodisplay").hide().prop('disabled', true);

  // Hide the school fields if not from NZ, on user edit and registration pages
  if ($("#user_country_code").length) {
    on_country_change();
    $("#user_country_code").on('change', on_country_change);
  }

  $(".countdown").each(function() {
    var finalDate, format = $(this).data('format');
    if ($(this).data('duration') != undefined) {
      finalDate = (new Date().valueOf() + Math.floor(parseFloat($(this).data('duration'))*1000));
    }
    else {
      finalDate = $(this).data('countdown'); 
    }
    $(this).countdown(finalDate, function(event) {
      if (format.substring(0,3) == "%th") {
        var th = event.offset.totalDays*24 + event.offset.hours;
        $(this).html(th + event.strftime(format.substring(3)));
      }
      else $(this).html(event.strftime(format));
    });
  });

  $("#main").focus();
});
