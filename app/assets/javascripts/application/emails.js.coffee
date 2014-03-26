$(document).on "change", "#who", ->
	if $(this).val() == "everyone"
		$(".filter_options, .one_options").hide()
		$("#filters_container").find(".filter").remove()
	else if $(this).val() == "filter"
		$(".filter_options").show()
		$(".one_options").hide()
		Filters.add "name", "like", "" if !$("#filters_container").find(".filter").length
	else if $(this).val() == "one"
		$(".one_options").show()
		$(".filter_options").hide()