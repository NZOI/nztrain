$(function () {
    $('.pagination a').live("click", function() {
        // push hash/anchor state on URL
        var state = {};
        state['page']=$.deparam.querystring(this.href).page;
        $.bbq.pushState(state);
        
        return false; // cancel normal link action
    });

    $(window).bind( 'hashchange', function(e) {
	var img = document.createElement("IMG");
	img.src = "/images/ajax-loader.gif";
        $(img).css({'margin': '100px'});
        var div = document.createElement("DIV");
        $(div).append(img);
        $(div).css({'position': 'absolute', 'left': 0, 'top': 0, 'width': '100%', 'height': '100%', 'background-color': 'rgba(255,255,255,0.7)', 'text-align': 'center', 'opacity': 0.9});
	$('#paginated_content').append(div);
	$('.pagination a').css({'opacity': 0.5, 'cursor': 'default'});
	$('.pagination a').click(function() { e.preventDefault(); return false; })

        // scroll to top of paginated_section if it is not visible
        if ($('body').scrollTop() > $('#paginated_section').offset().top) {
            $('body').scrollTop($('#paginated_section').offset().top);
        }

        $.getScript($.param.querystring(document.location.href, {'page': $.deparam.fragment().page })); // get new content
    });

    if ($.deparam.fragment().page) {
        $('#paginated_content').html(""); // empty the content
        $(window).trigger('hashchange');
    }
});
