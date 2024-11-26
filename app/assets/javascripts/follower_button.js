
import 'jquery_ujs'
import $ from 'jquery';
window.$ = $;


$(document).on('turbo:load', function() { // For Turbo compatibility
  $('.follow-btn').onclick(function() {
    var userId = $(this).data('user-id');
    var $button = $(this); // Cache the button element for reuse

    $.ajax({
      url: "/users/" + userId + "/follow",
      method: "POST",
      success: function(data) {
        if (data.success) {
          $button.text("Following").prop("disabled", true); // Update button
        } else {
          alert(data.error || "Something went wrong.");
        }
      },
      error: function(xhr) {
        alert("Error: " + xhr.responseText);
      }
    });
  });
});
