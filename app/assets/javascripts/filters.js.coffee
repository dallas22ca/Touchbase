$(document).on "change", "#who", ->
  if $(this).val() == "everyone"
    $(".filter_options").hide()
    $("#filters_container").find(".filter").remove()
  else if $(this).val() == "filter"
    $(".filter_options").show()
    Filters.add "name", "is", "" if !$("#filters_container").find(".filter").length

$(document).on "submit", ".edit_followup, #new_followup", ->
  $("#filter_template").find(".filter_field").removeAttr("name")

$(document).on "change", ".filter_permalink", ->
  filter = $(this).closest(".filter")
  string = filter.find(".filter_string")
  search = filter.find(".filter_search").val()
  string.val "" if search == "true" || search == "false"

$(document).on "keyup change", ".filter_field", ->
  Filters.calc()

$(document).on "click", ".add_filter", ->
  Filters.add "name", "is", ""
  false

$(document).on "click", ".delete_filter", ->
  Filters.remove $(this)
  false

@Filters =
  init: ->
    if $("#filters_container").length
      criteria = $("#filter_template").data("criteria")
      
      if criteria.length
        for crit in criteria
          Filters.add crit[0], crit[1], crit[2]
        $("#who").val("filter").change()
      else
        $("#who").val("everyone").change()
        
      Filters.calc()

  calc: ->
    if $("#filters_container").length
      filters = $("#filter_template").data("filters")
    
      $(".filter").each ->
        permalink = $(this).find(".filter_permalink").val()
        search = $(this).find(".filter_search")
        applicable = ".filter_#{filters[permalink].data_type}"

        search.val $(this).find(applicable).val()
        
        $(this).find(".filter_field:not(.filter_matcher, .filter_permalink)").hide()
        $(this).find(applicable).show()
      
  add: (permalink = false, matcher = false, search = false)->
    template = $("#filter_template").clone().removeAttr("id")
    template.find(".filter_permalink").val permalink if permalink
    
    if matcher
      template.find(".filter_matcher").val matcher
    
    if search
      template.find(".filter_search").val search
      template.find(".filter_string").val search
      template.find(".filter_boolean").val search
    template.appendTo "#filters_container"
  
  remove: (el) ->
    el.closest(".filter").remove()