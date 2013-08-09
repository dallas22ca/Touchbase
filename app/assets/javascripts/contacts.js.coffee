$(document).on "click", "#contacts th", ->
  permalink = $(this).data("permalink")
  data_type = $(this).data("data_type")
  
  if $("#contacts").data("order") == permalink
    if $("#contacts").data("direction") == "asc"
      $("#contacts").data("direction", "desc")
    else
      $("#contacts").data("direction", "asc")
  else
    $("#contacts").data("order", permalink)
    $("#contacts").data("direction", "asc")
    
  $("#contacts").data("data_type", data_type)
  $("#contacts_search").submit()

$(document).on "keyup click", ".search_field", ->
  $("#contacts_search").submit()

$(document).on "click", ".filter_checkbox", ->
  if $(this).is(":checked")
    $(this).closest(".field").removeClass "inactive"
    $(this).closest(".field").find("input:visible:eq(1), textarea:visible:eq(1)").focus()
  else
    $(this).closest(".field").addClass "inactive"
  
  $("#contacts_search").submit()

$(document).on "submit", "#contacts_search", ->
  args = []
  url = $(this).attr("action")
  q = $("#q").val()
  direction = $("#contacts").data("direction")
  order = $("#contacts").data("order")
  data_type = $("#contacts").data("data_type")
  
  $(".field:not(.inactive) .search_field").each ->
    matcher = $(this).data("matcher")
    field = $(this).attr("name")
    search = $(this).val()
    
    unless $(this).is(":radio") && !$(this).is(":checked")
      args.push [field, matcher, search]

  $.get url, 
    search: args
    q: q
    order: order
    direction: direction
    data_type: data_type
  , (data) ->
    eval data
  false

@Import =
  poll: ->
    ip = $("#import_progress")
    if ip.data("progress") != 100
      url = ip.data("url")
      $.getScript url