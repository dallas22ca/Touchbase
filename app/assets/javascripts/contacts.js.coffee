$(document).on "click", ".filter_checkbox", ->
  if $(this).is(":checked")
    $(this).closest(".field").removeClass "inactive"
    $(this).closest(".field").find("input:visible, textarea:visible").focus()
  else
    $(this).closest(".field").addClass "inactive"
    # $("#contacts_search").submit()

$(document).on "submit", "#contacts_search", ->
  args = []
  url = $(this).attr("action")
  q = $("#q").val()
  
  $(".field:not(.inactive) .search_field").each ->
    matcher = $(this).data("matcher")
    field = $(this).attr("name")
    search = $(this).val()
    args.push [field, matcher, search]

  $.get url, 
    search: args
    q: q
  , (data) ->
    eval data
  false