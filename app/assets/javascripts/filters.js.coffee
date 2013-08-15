$(document).on "change", "#who", ->
  if $(this).val() == "everyone"
    $(".filter_options").hide()
    $("#filters_container").find(".filter").remove()
  else if $(this).val() == "filter"
    $(".filter_options").show()
    Filters.add "name", "like", "" if !$("#filters_container").find(".filter").length

$(document).on "submit", ".edit_followup, #new_followup", ->
  $("#filter_template").find(".filter_field").removeAttr("name")

$(document).on "change", ".filter_permalink", ->
  filter = $(this).closest(".filter")
  string = filter.find(".filter_string")
  search = filter.find(".filter_search").val()
  string.val "" if search == "true" || search == "false"
  Filters.setMatcherField filter

$(document).on "keyup change", ".filter_field", ->
  Filters.calc()

$(document).on "click", ".add_filter", ->
  Filters.add "name", "like", ""
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
        data_type = filters[permalink].data_type
        applicable = ".filter_#{data_type}"

        search.val $(this).find(applicable).val()
        $(this).find(".filter_field:not(.filter_matcher, .filter_permalink)").hide()
        $(this).find(applicable).show()
      
  add: (permalink = false, matcher = false, search = false)->
    template = $("#filter_template").clone().removeAttr("id")
    template.find(".filter_permalink").val permalink
    
    Filters.setMatcherField template
    
    if matcher
      template.find(".filter_matcher").val matcher
    
    if search
      template.find(".filter_search").val search
      template.find(".filter_string").val search
      template.find(".filter_boolean").val search
    template.appendTo "#filters_container"
  
  remove: (el) ->
    el.closest(".filter").remove()
  
  setMatcherField: (template, matcher = false) ->
    filters = $("#filter_template").data("filters")
    permalink = template.find(".filter_permalink").val()
    matcher_field = template.find(".filter_matcher")
    matcher_field.find("option").remove()
    
    for opt in Filters.matcherOptions(filters[permalink].data_type)
      option = $("<option>").val(opt[1]).text(opt[0])
      option.appendTo matcher_field
      
    matcher_field.val matcher if matcher

  matcherOptions: (type) ->
    if type == "boolean"
      [["is", "is"], ["is not", "is_not"]]
    else if type == "integer"
      [["is", "like"], ["is not", "is_not"], ["is exactly", "is"], ["greater than", "greater_than"], ["less than", "less_than"]]
    else
      [["is", "like"], ["is not", "is_not"], ["is exactly", "is"]]