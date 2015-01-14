$(document).ready( function() {
  var tags = $('#tag-data').data('tags')

  $('#tags-input').keyup(function() {
    var userInput = $(this)[0].value.split(', ').pop(),
          result = [];

      if(userInput){
        detectMatchingTags(userInput, result);
        displayMatchingTags(result);
      };
    });

  var detectMatchingTags = function(userInput, result) {
    tags.map(function(tag) {
      if(tag.match(userInput)){
        result.push("<span class='tag-matcher'>"+ tag + '</span>');
      };
    });
  };

  var displayMatchingTags = function(result){
    $('#tag-data').html(result.splice(0, 9));
  };

});
