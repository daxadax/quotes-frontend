$(document).ready( function() {
  var defaultBackground = $('body').css('background');

  $('.remove-duplicate-quote').mousedown(function() {
    $(this).parent().siblings('.duplicate-quotes-confirmation').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    $(this).parent().parent().css('background', '#d9534f');
    $(this).parent().addClass('hide');
  });

  $('.add-duplicate-quote').mousedown(function() {
    var quote = $(this).parent().siblings('.duplicate-quotes-holder').data('quote'),
          path = $(this).parent().siblings('.duplicate-quotes-holder').data('path');

    $(this).parent().siblings('.duplicate-quotes-confirmation').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    $(this).parent().parent().css('background', '#5cb85c');
    submitQuote(path, quote, $(this).parent().parent());
    $(this).parent().addClass('hide');
  });

  $('.cancel').mousedown(function() {
    $(this).parent().siblings('.duplicate-quotes-btn-holder').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').removeClass('hide');
    $(this).parent().parent().css('background', defaultBackground);
    $(this).parent().addClass('hide');
  });

  $('.star').mousedown(function() {
      var quote_uid = $(this).data('uid'),
        current_user = $(this).data('currentUser');

    if(current_user != null){
      var path = "/toggle_star/" + quote_uid,
        el = $(this);

      $.post(path).success(function() {
        toggleFavoriteClass(el);
      });
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
    submitQuote(path, data, container);
  });

  var submitQuote = function(path, data, container){
    $.post(path, data).done(function(e){

      if( path.match(/edit/) != null ){
        // edit returns the redirect path
        container.load(e);
      } else {
        // new returns a json object
        redirectAfterCreate(e, container);
      };
      return false;
    });
  };

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
