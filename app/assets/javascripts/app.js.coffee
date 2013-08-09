$(document).on "click", ".disabled", ->
  false

$(document).on "click", "#nav a", ->
  unless $(this).hasClass "disabled"
    $("#nav .selected").removeClass "selected"
    $(this).addClass "selected"

unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  setTimezone()
  Followup.initOffset()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load