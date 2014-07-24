$(document).ready( function() {

  $('.star').mousedown(function() {
    var quote_id = $(this).data('id');

    $(this).parent('.star-holder').load(
      "/toggle_star?" + $.param({ id: quote_id })
    );
  });

});