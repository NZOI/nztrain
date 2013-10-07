/*
// This file is used to delegate <a rel="facebox" /> links to the facebox jquery plugin.
// This is preferred over binding on page-load, in case any additional facebox links are
// loaded via AJAX.
*/

jQuery(document).ready(function($) {
  $(document).on('click.facebox', 'a[rel*=facebox]', function(e) {
    $(this).facebox();
    $(this).trigger('click.facebox');
    return false;
  });
});
