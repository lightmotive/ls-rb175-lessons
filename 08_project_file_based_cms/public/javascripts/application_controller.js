// Show flash message HTML (for XHR rendering).
// Remove existing flash messages.
function flashMessages(content) {
  $('main .flash').remove();
  $('main').prepend(content);
}