unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  setTimezone()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load

@setTimezone = ->
  if $("#new_user").length
    tz = jstz.determine()
    name = tz.name()
    $("#user_time_zone").val name
    
    