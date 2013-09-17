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
    dateFormat: "MM d, yy"
  
  $("#fields tbody").disableSelection().sortable
    items: "tr"
    handle: ".handle"
    axis: "y"
    helper: (e, tr) ->
      originals = tr.children()
      helper = tr.clone()
      helper.children().each (index) ->
        $(this).width originals.eq(index).width()
      helper
    start: (e, tr) ->
      tr.placeholder.height tr.item.height()
      tr.placeholder.width tr.item.closest("table").width()
    update: (e, tr)->
      $("#fields tbody").find("tr").each (index) ->
        $(this).find(".ordinal").val index
  
  $(".show_contacts_format").change() if $("#new_contact").length
    
  $("#loading").fadeOut()
  Followup.init()
  Filters.init()
  Contacts.paginate()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load