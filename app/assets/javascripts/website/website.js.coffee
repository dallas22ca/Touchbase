unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load