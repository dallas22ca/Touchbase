$(document).on "click", ".task_checkbox", ->
  task = $(this).closest(".task")
  url = task.data("url")
  
  if $(this).is ":checked"
    complete = true
    task.addClass "complete"
    task.appendTo "#complete_tasks"
  else
    complete = false
    task.removeClass "complete"
    task.prependTo "#incomplete_tasks"
  
  $.post url,
    _method: "patch"
    format: "js"
    "task[complete]": complete