$ ->
  if $("#new_user").length
    tz = jstz.determine()
    $("#user_time_zone").val tz.name()