//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require jquery-ui-timepicker-addon
//= require jquery.event.hover-1.0
//= require jquery.fileinput
//= require jquery.countdown
//= require jquery.ba-bbq
//= require jquery.markitup
//= require jquery.url
//= require sets/markdown/set
//= require superfish
//= require history
//= require jquery.facebox
//= require jquery.facebox.adapter
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

    $("table.selectable > tbody > tr").click(function() {
    	$(this).toggleClass("selected_row");
    });

    $("#nav > ul").superfish({
        animation: {opacity:'show',height:'show'},
        speed: 'fast'
    });
    $("#nav2 ul").superfish({
        autoArrows: false,
        speed: 'fast'
    });

    $('.markdown').markItUp(myMarkdownSettings);
    $('.date-picker').datetimepicker({ dateFormat: 'dd/mm/yy' });

    $('#menu').css({'min-width':$('#nav').width()+$('#controls').width() + 'px'});

    $(".submission_details").click(function() {
        console.log("abc");
        $(this).find(".submission_details_hider").slideDown();
    });
    $(".submission_details_hider").hide();
});
