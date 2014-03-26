$(document).on "click", ".disabled", ->
  false

$(document).on "click", "#nav a", ->
  unless $(this).hasClass "disabled"
    $("#nav .selected").removeClass "selected"
    $(this).addClass "selected"

unload = ->
  $("#loading").show()

load = ->
  $("#email_contact_id").chosen()

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
  
  Followup.init()
  Filters.init()
  Contacts.paginate()
	
  $(".show_contacts_format").trigger("change") if $("#new_contact").length
  $("#who").trigger("change") if $("#who").length
  $("#loading").fadeOut()
  
$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load