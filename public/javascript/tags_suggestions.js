$(document).ready( function() {

  suggestTags();
  contentInput.focus(function() { beginSuggesting() });
  contentInput.blur(function() { stopSuggesting() });

  $('#suggested-tags').on('mousedown', '.suggested-tag', function() {
      var tag = $(this).text(),
            tagsInput = $('#tags-input');

      console.log('tag', tag);

      tagsInput.val( tagsInput.val() + ', ' + tag )
      suggestedTags.splice( $.inArray(tag, suggestedTags), 1 )
      displaySuggestedTags();
  });

});

var availableTags = $('#tag-data').data('tags'),
      contentInput = $('textarea#content-input'),
      suggestedTagsHolder = $('#suggested-tags'),
      suggestedTags = [],
      interval;

var beginSuggesting = function() {
  interval = setInterval(suggestTags, 1000);
}

var stopSuggesting = function() {
  clearInterval(interval);
}

var suggestTags = function() {
  var content = contentInput.val();

  availableTags.map(function(tag) {
    if(content.match(tag)) {
      suggestTag(tag);
    };
  });

  displaySuggestedTags();
};

var suggestTag = function(tag) {
  var currentTags = $('#tags-input').val().split(', ');

  if( $.inArray(tag, currentTags) == -1 ){
    if( $.inArray(tag, suggestedTags) == -1){
      suggestedTags.push(tag);
    };
  };
};

var displaySuggestedTags = function() {
  suggestedTagsHolder.html(
    "<span class='suggested-tag'>" +
    suggestedTags.join("</span><span class='suggested-tag'>") +
    '</span>'
  );
};
