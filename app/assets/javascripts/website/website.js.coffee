@signedInEveryPage = ->
  window.editor = CodeMirror.fromTextArea $("#document_body")[0], 
    matchBrackets: true
    smartIndent: true
    lineWrapping: true
    lineNumbers: true
    theme: "lesser-dark"
    mode: "css"

  $(".nav:not(.social)").sortable
    placeholder: "editable_placeholder"
    start: (e, ui) ->
      html = $(ui.item).html()
      $(".editable_placeholder").append html
    update: (e, ui) ->
      id = $(this).data("page-id")
      $.post $("body").data("save_path"),
        page_id: $("body").data("page_id")
        pages: $(this).sortable("toArray")
        path: $("body").data("path")

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
      createSnapshot()

signedIn = ->
  $(document).on "click", "html, body", (e) ->
    if !$(e.target).parents(".editable").length
      $("[contenteditable]").removeAttr "contenteditable"

  $(document).on "click", ".editable h3, .editable h4, .editable p, .editable .ordered_list, .editable .unordered_list, .editable blockquote", ->
    $(this).attr "contenteditable", true
    $(this).focus()
  
  $(document).on "click", ".edit_layout_file", ->
    if $(".edit_document").is(":visible")
      $("#widget_home li").show()
      $(".edit_document").hide 150
      $("body, html").css "overflow", "auto"
    else
      $("#widget_home li:not(.code_editor_tool)").hide()
      $(".edit_document").show 150
      window.editor.refresh()
      $("body, html").css "overflow", "hidden"
    false
  
  $(document).on "submit", ".edit_document", ->
    location.reload()

  $(document).on "blur", "[contenteditable]", ->
    $("body").addClass "mid_edit"
  
    setTimeout ->
      if $(".mid_edit").length
        $("[contenteditable]").removeAttr "contenteditable"
        $("body").removeClass "mid_edit"
        createSnapshot()
    , 1111
  
  $(document).on "click", ".editable_delete", ->
    $(this).parent().remove()
    createSnapshot()
    false

  $(document).on
    mouseenter: ->
      if !$(".editable_placeholder").length && !$("*:focus").length
        handle = $("<i>").addClass("icon-move editable_handle")
        trash = $("<i>").addClass("icon-trash editable_delete")
        handle.css("width", $(this).width())
        handle.prependTo $(this)
        trash.prependTo $(this)
    mouseleave: ->
      if !$(".editable_placeholder").length
        $(".editable_handle, .editable_delete").remove()
    click: ->
      $(".editable_handle, .editable_delete").remove()
  , ".editable h3, .editable h4, .editable p, .editable blockquote, .editable .ordered_list, .editable .unordered_list, .editable .widget, .editable .img_wrapper"

  $(document).on "click", "[data-action]", (e) ->
    action = $(this).data("action")
    $("body").removeClass "mid_edit"
    document.execCommand action, false
    createSnapshot()
    false
  
  $(document).on "click", "[data-snapshot]", ->
    action = $(this).data("snapshot")
    useSnapshot(action)
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

createSnapshot = ->
  $("#snapshots .current").removeClass "current"
  html = $("<div>").addClass "snapshot current"
  html.html $("#main").html()
  $("#snapshots").prepend html

useSnapshot = (action) ->
  if action == "Undo"
    if $("#snapshots .current").next().length
      $("#snapshots .current").removeClass("current").next().addClass("current")
      $("#main").html $("#snapshots .current").html()
  else
    if $("#snapshots .current").prev().length
      $("#snapshots .current").removeClass("current").prev().addClass("current")
      $("#main").html $("#snapshots .current").html()
  signedInEveryPage()

unload = ->
  $("#loading").show()

load = ->
  $("#loading").fadeOut()
  
  if $(".user-signed-in").length
    signedInEveryPage()
    createSnapshot()

$ ->
  load()

  if $(".user-signed-in").length
    signedIn()

document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load