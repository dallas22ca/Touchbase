$(document).on "click", ".disabled", ->
  false

$(document).on "click", "#nav a", ->
  unless $(this).hasClass "disabled"
    $("#nav .selected").removeClass "selected"
    $(this).addClass "selected"

unload = ->
  $("#loading").show()

load = ->
  $(".datepicker").datepicker
    dateFormat: "M d, yy"
    
  $("#loading").fadeOut()
  setTimezone()
  Followup.init()
  Filters.init()
  Contacts.paginate()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load