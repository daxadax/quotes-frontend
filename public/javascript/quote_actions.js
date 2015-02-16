$(document).ready( function() {

  $('.star').mousedown(function() {
    var quote_uid = $(this).data('uid'),
          current_user = $(this).data('currentUser');

    if(current_user != null){
      var path = "/toggle_star/" + quote_uid;

      $(this).load(path);
      toggleFavoriteClass($(this));
    }
  });

  $('.edit').mousedown(function() {
    var path = $(this).data('path'),
          container = $(this).closest('.quote');

    // container.html('').attr('src', '/images/ajax-loader.gif');
    container.load(path);
  });

  $('#submit-quote').mousedown(function(){
    var path = $(this).data('path'),
          data = buildQuoteObjectFromFormInput(),
          container = $(this).closest('.quote');

    // container.attr('src', '/images/ajax-loader.gif');
    $.post(path, data).done(function(e){

      if( path.match(/edit/) != null ){
        // edit always returns the redirect path
        container.load(e);
      } else {
        // new returns a json object
        redirectAfterCreate(e, container);
      };
      return false;
    });
  });

  var redirectAfterCreate = function(e, container){
    var response = $.parseJSON(e);
    if( response['uid'] != null ){
      if( container.length ){
        container.load('/quote_partial/' + response['uid']);
      } else {
        location.href = '/quote/' + response['uid'];
      };
    } else {
      location.reload(true)
    };
  };

  var buildQuoteObjectFromFormInput = function(){
    return {
      publication_uid: $('select[name=publication_uid]').val(),
      content: $('textarea[name=content]').val(),
      page_number: $('input[name=page_number]').val(),
      tags: $('input[name=tags]').val()
    }
  };

  var toggleFavoriteClass = function(el){
    if(el.hasClass('favorite')) {
      el.removeClass('favorite')
    } else {
      el.addClass('favorite')
    };
  };

});
