//= require jquery
//= require jquery-1.6.2.min
//= require jquery-ui-1.8.16.custom.min
//= require jquery-ui-timepicker-addon
//= require jquery.fileinput
//= require jquery.countdown.js
//= require jquery.ba-bbq.min
//= require markitup/jquery.markitup
//= require markitup/sets/markdown/set.js
//= require superfish
//= require jquery.event.hover-1.0
//= require pagination
//= require_self


// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
$(document).ready(function() {
    $('.markdown').markItUp(myMarkdownSettings);
    $('.date-picker').datetimepicker();
});
