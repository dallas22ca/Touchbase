signedIn = ->
  $(document).on "click", "html, body", (e) ->
    if !$(e.target).parents(".editable").length
      $("[contenteditable]").removeAttr "contenteditable"

  $(document).on "click", ".editable h3, .editable h4, .editable p, .editable .ordered_list, .editable .unordered_list, .editable blockquote", ->
    $(this).attr "contenteditable", true
    $(this).focus()

  $(document).on "blur", "[contenteditable]", ->
    $("body").addClass "mid_edit"
  
    setTimeout ->
      if $(".mid_edit").length
        $("[contenteditable]").removeAttr "contenteditable"
        $("body").removeClass "mid_edit"
    , 10

  $(document).on
    mouseenter: ->
      if !$(".editable_placeholder").length && !$("*:focus").length
        i = $("<i>").addClass("icon-move editable_handle")
        i.css("width", $(this).width())
        i.prependTo $(this)
    mouseleave: ->
      if !$(".editable_placeholder").length
        $(".editable_handle").remove()
    click: ->
      $(".editable_handle").remove()
  , ".editable h3, .editable h4, .editable p, .editable blockquote, .editable .ordered_list, .editable .unordered_list, .editable .widget, .editable .img_wrapper"

  $(document).on "click", "[data-action]", (e) ->
    action = $(this).data("action")
    $("body").removeClass "mid_edit"
    document.execCommand action, false
    false

  $(document).on "keydown", "[contenteditable]", (e) ->
    if !$(this).hasClass("ordered_list") && !$(this).hasClass("unordered_list")
      code = ((if e.keyCode then e.keyCode else e.which))
      if code is 13
        document.execCommand "insertHTML", false, "<br>"
        false

  $(document).on "later", "[contenteditable]", ->
    s = new Sanitize
      elements: ["a", "br", "b", "strong", "em", "i", "u", "s"]
      attributes:
        a: ["href"]
  
    $(this).html s.clean_node($(this)[0])

  $(document).on "paste", "[contenteditable]", ->
    el = $(this)
  
    setTimeout ->
      el.blur().focus()
    , 0

unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  
  if $(".user-signed-in").length
    
    $(".nav").sortable
      placeholder: "editable_placeholder"
      start: (e, ui) ->
        html = $(ui.item).html()
        $(".editable_placeholder").append html

    $("#widget_home .draggable").draggable
      connectToSortable: ".editable"
      helper: ->
        type = $(this).data("type")
        template = $("#templates .#{type}").clone()
        template
      start: ->
        $("body").addClass "dragging"
  
    $(".editable").sortable
      items: "h3, h4, p, blockquote, .ordered_list, .unordered_list, .img_wrapper, .widget"
      connectWith: ".editable"
      placeholder: "editable_placeholder"
      helper: "editable_helper"
      handle: ".editable_handle"
      cancel: "[contenteditable]"
      start: (e, ui) ->
        if ui.item.hasClass "draggable"
          type = ui.item.data("type")
          template = $("#templates .#{type}").clone()
          $(".editable_placeholder").append template
          $(ui.item).addClass("editable_helper")
        else
          html = $(ui.item).html()
          $(".editable_placeholder").append(html).addClass(ui.item.attr("class"))
          $(ui.item).addClass("editable_helper")
      stop: (e, ui) ->
        ui.item.removeClass("editable_helper")
        type = ui.item.data("type")

        if ui.item.hasClass "draggable"
          template = $("#templates .#{type}").clone().html()
          ui.item.replaceWith template
        
        $("body").removeClass "dragging"

$ ->
  load()

  if $(".user-signed-in").length
    signedIn()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load