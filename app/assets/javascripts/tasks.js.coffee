$(document).on "click", ".task_checkbox", ->
  task = $(this).closest(".task")
  tasks_for_date = task.closest(".tasks_for_date")
  date = parseFloat task.data("date")
  url = task.data("url")
  
  if $(this).is ":checked"
    complete = true
    task.addClass "complete"
    task.appendTo "#complete_tasks"
    tasks_for_date.hide() unless tasks_for_date.find(".task").length
    $("#incomplete_tasks .placeholder").show() unless $("#incomplete_tasks").find(".task").length
    $("#completed_tasks_wrapper").show()
  else
    complete = false
    task.removeClass "complete"
    
    $(".tasks_for_date").each ->
      start = parseFloat $(this).data("start")
      finish = parseFloat $(this).data("finish")
      
      if start <= date && date <= finish
        list = $(this)
      
    if !list
      list = $(".overdue_list")
      
    task.appendTo list
    list.show()

    $("#completed_tasks_wrapper").hide() unless $("#completed_tasks_wrapper").find(".task").length
    $("#incomplete_tasks .placeholder").hide() if $("#incomplete_tasks").find(".task").length
  
  $.post url,
    _method: "patch"
    format: "js"
    "task[complete]": complete