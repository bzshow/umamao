$(document).ready(function() {
  $('.user-info').delegate('.profile_inline_editable', 'mouseover', function(){
    $('.profile_inline_editable .edit_link').show();
  });
});
