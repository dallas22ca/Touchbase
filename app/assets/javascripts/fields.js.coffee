$(document).on "click", ".remove_fields", () ->
	$(this).prev('input[type=hidden]').val('1')
	$(this).closest('tr').hide()
	false

$(document).on "click", ".add_fields, .add_suggested_field", ->
  button = $(".add_fields")
  id = button.data("id")
  time = new Date().getTime()
  regexp = new RegExp(id, 'g')
  association = $(button).attr("id").replace("add_", "")
  h = button.data("fields").replace(regexp, time)
  html = $(h)
  
  if $(this).hasClass "add_suggested_field"
    title = $(this).data("title")
    permalink = $(this).data("permalink")
    data_type = $(this).data("data-type")
    html.find(".title").val title
    html.find(".permalink").val permalink
    html.find(".data_type").val data_type
    $(this).hide()
  
  $("##{association} tbody").append html
  false