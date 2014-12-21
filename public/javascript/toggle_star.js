$(document).ready( function() {

  $('.star').mousedown(function() {
    var quote_uid = $(this).data('uid'),
          current_user = $(this).data('currentUser');

    if(current_user != null){
      toggleFavoriteStatus($(this), quote_uid);
      toggleFavoriteClass($(this));
    }

  });

  var toggleFavoriteStatus = function(el, quote_uid){
    el.load(
      "/toggle_star/" + quote_uid
    )
  };

  var toggleFavoriteClass = function(el){
    if(el.hasClass('favorite')) {
      el.removeClass('favorite')
    } else {
      el.addClass('favorite')
    };
  };

});
