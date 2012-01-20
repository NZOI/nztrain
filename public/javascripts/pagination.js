$(function () {
    $('.pagination a').live("click", function() {
        // push hash/anchor state on URL
        var state = {};
        state['page']=$.deparam.querystring(this.href).page;
        $.bbq.pushState(state);
        
        return false; // cancel normal link action
    });

    $(window).bind( 'hashchange', function(e) {
        $('#pagination_content').css({opacity: 0.5}); // loading visual cue - maybe add an animation later

        $.getScript($.param.querystring(document.location.href, {'page': $.deparam.fragment().page })); // get new content
    });

    if ($.deparam.fragment().page) {
        $('#pagination_content').html(""); // empty the content
        $(window).trigger('hashchange');
    }
});
