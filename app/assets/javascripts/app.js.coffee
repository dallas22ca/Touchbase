$(document).on "click", ".disabled", ->
  false

$(document).on "click", "#nav a", ->
  $("#nav .selected").removeClass "selected"
  $(this).addClass "selected"

unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  setTimezone()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load