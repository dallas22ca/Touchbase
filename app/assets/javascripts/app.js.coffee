$ ->
  document.addEventListener "page:receive", load()

load = ->
  setTimezone()