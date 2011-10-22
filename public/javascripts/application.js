// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
$(document).ready(function() {
    $('.markdown').markItUp(myMarkdownSettings);
    $('.date-picker').datetimepicker();
    //make tables look good
    $("th").each(function(){

        $(this).addClass("ui-state-default");

    });
    $("td").each(function(){

        $(this).addClass("ui-widget-content");

    });
    $("tr").hover(
        function()
        {
            $(this).children("td").addClass("ui-state-hover");
        },
        function()
        {
            $(this).children("td").removeClass("ui-state-hover");
        }
        );
    $("tr").click(function(){

        $(this).children("td").toggleClass("ui-state-highlight");
    });
    //make buttons look good
    $("#file-form").fileinput();
    $("input:submit").button().css({
        'margin' : '0',
        'vertical-align' : 'top'
    });
    $('input:text, input:password, input[type=email]')
        .button()
        .css({
            'font' : 'inherit',
            'color' : 'inherit',
            'text-align' : 'left',
            'outline' : 'none',
            'cursor' : 'text',
        });

    $("select").attr("class", "ui-button ui-widget ui-state-default ui-corner-all").css({
        'font' : 'inherit',
        'color' : 'inherit',
        'text-align' : 'left',
        'outline' : 'none',
        'cursor' : 'text',
    });

});
