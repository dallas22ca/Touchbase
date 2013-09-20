$(document).on
  mouseenter: ->
    $(this).find(".icon-trash, .icon-edit").show()
  mouseleave: ->
    $(this).find(".icon-trash, .icon-edit").hide()
, ".task"

$(document).on "click", ".show_tasks_format", ->
  value = $(this).val()
  
  if value == "general"
    $("#new_followup").hide()
    $("#new_task").show()
  else if value == "followup"
    $("#new_followup").show()
    $("#new_task").hide()

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
    list = false
    complete = false
    task.removeClass "complete"
    
    $(".tasks_for_date").each ->
      start = parseFloat $(this).data("start")
      finish = parseFloat $(this).data("finish")
      
      if start <= date && date <= finish
        list = $(this)
      
    list = $(".overdue_list") unless list
      
    task.appendTo list
    list.show()

    $("#completed_tasks_wrapper").hide() unless $("#completed_tasks_wrapper").find(".task").length
    $("#incomplete_tasks .placeholder").hide() if $("#incomplete_tasks").find(".task").length
  
  $.post url,
    _method: "patch"
    format: "js"
    "task[complete]": complete