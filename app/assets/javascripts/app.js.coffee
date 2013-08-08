$(document).on "click", ".disabled", ->
  false

unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  setTimezone()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load