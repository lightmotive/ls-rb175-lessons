function deleteFormSubmitHandler(event) {
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
}

function renameGetLinkClickHandler(event) {
  event.preventDefault();
  event.stopPropagation();

  let link = $(this);

  let renameRequest = $.ajax({
    url: link.attr("href"),
    method: link.attr("get")
  });

  renameRequest
    .done(function (data, _textStatus, jqXHR) {
      if (jqXHR.status === 200) {
        // `data` => HTML form for renaming entry
        showInlineEditorForm(link.parent("li"), data);
      }
    })
    .fail(function (jqXHR, _textStatus, _errorThrown) {
      if (jqXHR.status === 400) {
        flashMessages(jqXHR.responseText);
      }
    });
}

function renameSaveFormSubmitHandler(event) {
  event.preventDefault();
  event.stopPropagation();

  let form = $(this);

  let request = $.ajax({
    url: form.attr("action"),
    method: form.attr("method"),
    data: form.serialize()
  });

  request
    .done(function (data, _textStatus, jqXHR) {
      console.log(data, jqXHR);
      if (jqXHR.status === 200) {
        document.location = data;
      }
    })
    .fail(function (jqXHR, _textStatus, _errorThrown) {
      if (jqXHR.status === 400) {
        flashMessages(jqXHR.responseText);
      }
    });
}

// Reusable function that:
// - Clones viewParent element, hides it, and inserts the clone after viewParent.
// - Adds form HTML to the clone.
// - Adds default cancel link click handler to inline editor form that removes
//   clone and unhides parent.
function showInlineEditorForm(viewParent, formHTML) {
  let editorParent = viewParent.clone().empty();
  viewParent.addClass(["hidden", "editing"]);
  viewParent.after(editorParent);
  editorParent.html(formHTML);
  editorParent.find("input").focus().select();

  editorParent.find("form.rename").on("submit", renameSaveFormSubmitHandler);

  editorParent.find("form a.cancel").on("click", function (event) {
    cancelInlineEditorForm(event, editorParent, viewParent)
  });
}

function cancelInlineEditorForm(event, editorParent, hiddenViewParent) {
  event.preventDefault();
  event.stopPropagation();

  editorParent.remove();
  hiddenViewParent.removeClass(["hidden", "editing"]);
}

$(function () {
  $("form.delete").on("submit", deleteFormSubmitHandler);
  $("a.rename").on("click", renameGetLinkClickHandler);
});