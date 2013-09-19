$(document).on "click", "html, body", (e) ->
  if !$(e.target).parents(".editable").length
    $("[contenteditable]").removeAttr "contenteditable"

$(document).on "click", ".editable h3, .editable h4, .editable h5, .editable h6, .editable p", ->
  $(this).attr "contenteditable", true

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
, ".editable h4, .editable h3, .editable p, .editable .widget"

$(document).on "click", "[data-action]", (e) ->
  action = $(this).data("action")
  $("body").removeClass "mid_edit"
  document.execCommand action, false
  false

$(document).on "keydown", "[contenteditable]", (e) ->
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
      helper: "clone"
  
    $(".editable").sortable
      items: "h6, h5, h4, h3, p, .widget"
      connectWith: ".editable"
      placeholder: "editable_placeholder"
      helper: "editable_helper"
      handle: ".editable_handle"
      cancel: "[contenteditable]"
      start: (e, ui) ->
        html = $(ui.item).html()
        $(".editable_placeholder").append html
        $(ui.item).addClass("editable_helper")
      stop: (e, ui) ->
        $(ui.item).removeClass("editable_helper")

$ ->
  load()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load