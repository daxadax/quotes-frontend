$(document).ready( function() {

  $('.quotes-hidden').mousedown(function() {
    $(this).addClass('hide');
    $(this).siblings('.quotes-displayed').removeClass('hide');
    $(this).siblings('.quotes-container').removeClass('hide');
  });

  $('.quotes-displayed').mousedown(function() {
    $(this).addClass('hide');
    $(this).siblings('.quotes-hidden').removeClass('hide');
    $(this).siblings('.quotes-container').addClass('hide');
  });

});
