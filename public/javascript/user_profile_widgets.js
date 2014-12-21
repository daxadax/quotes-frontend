$(window).load(function() {

  $('.widget').each(function() {
    var path = $(this).data('path');

    $(this).load(path);
  });

});
