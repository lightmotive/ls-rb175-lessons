$(function () {

  $("form.delete").on("submit", function (event) {
    event.preventDefault();
    event.stopPropagation();

    let form = $(this);
    let parent = form.parent("li");
    let entry_name = parent.children("a").first().text();
    let ok = confirm(`Are you sure you want to irreversibly delete ${entry_name}?`);
    if (ok) {
      let request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method")
      });

      request.done(function (data, _textStatus, jqXHR) {
        if (jqXHR.status === 204) {
          parent.remove();
        } else if (jqXHR.status === 200) {
          document.location = data;
        }
      });
    }
  });

});