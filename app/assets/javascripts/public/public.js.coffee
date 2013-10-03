unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  setTimezone()
  
$ ->
  load()

$(document).on "keyup", "#website_title", ->
  title = $("#website_title").val()
  permalink = title.replace(/[^a-z0-9]+/gi, "-").replace(/^-*|-*$/g, "").toLowerCase()
  $("#website_permalink").val permalink

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load

@setTimezone = ->
  if $("#new_user, #new_website").length
    tz = jstz.determine()
    name = tz.name()
    $("#user_time_zone, #website_users_attributes_0_time_zone").val name
    
    