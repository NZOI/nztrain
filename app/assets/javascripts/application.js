//= require jquery
//= require jquery_ujs
//= require jquery-1.6.2.min
//= require jquery-ui-1.8.16.custom.min
//= require jquery-ui-timepicker-addon
//= require jquery.fileinput
//= require jquery.countdown.js
//= require jquery.ba-bbq.min
//= require jquery.markitup
//= require sets/markdown/set.js
//= require superfish
//= require jquery.event.hover-1.0
//= require pagination
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
        $("#"+id).animate({'height':$("#"+id).data("height")},Math.max(($("#"+id).data("height")-$("#"+id).height())/expandspeed,minduration));
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
    $('#menu').animate({'left':'60px'}, duration);
    $('#side-minify').html("&#9654;");
    $('#main').animate({'margin-left':'50px'}, duration);
    $('#side-expanded').animate({'opacity':'0'},duration);
    $('#side-contracted').animate({'opacity':'1'}, duration);
}

function expand() {
    createCookie("expanded", "true", 31);
    $("#side").animate({width:'200px'}, duration);
    $('#menu').animate({'left':'210px'}, duration);
    $('#side-minify').html("&#9664;");
    $('#main').animate({'margin-left':'200px'}, duration);
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

    $("table tr").click(function() {
    	$(this).toggleClass("main-table-highlight");
    });

    $("#nav ul").superfish({
        animation: {opacity:'show',height:'show'}
    });
    $("#nav2 ul").superfish({
        autoArrows: false
    });

    $('.markdown').markItUp(myMarkdownSettings);
    $('.date-picker').datetimepicker();
});
