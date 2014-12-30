$(document).ready( function() {

  $('#add-new-publication').mousedown(function() {
    $('#publication-holder').load('/publication/new');
  });

});
