$(document).on "click", ".disabled", ->
  false

unload = ->

load = ->
  setTimezone()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:receive", load