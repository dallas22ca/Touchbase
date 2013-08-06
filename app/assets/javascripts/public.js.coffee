@setTimezone = ->
  if $("#new_user").length
    tz = jstz.determine()
    name = tz.name()
    $("#user_time_zone").val name