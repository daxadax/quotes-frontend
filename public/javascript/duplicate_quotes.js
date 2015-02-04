$(document).ready( function() {
  var defaultBackground = $('body').css('background');

  $('.remove-duplicate-quote').mousedown(function() {
    $(this).parent().siblings('.duplicate-quotes-confirmation').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    $(this).parent().parent().css('background', '#d9534f');
    $(this).parent().addClass('hide');
  });

  $('.add-duplicate-quote').mousedown(function() {
    $(this).parent().siblings('.duplicate-quotes-confirmation').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    $(this).parent().parent().css('background', '#5cb85c');
    $(this).parent().addClass('hide');
  });

  $('.cancel').mousedown(function() {
    $(this).parent().siblings('.duplicate-quotes-btn-holder').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').removeClass('hide');
    $(this).parent().parent().css('background', defaultBackground);
    $(this).parent().addClass('hide');
  });

});
