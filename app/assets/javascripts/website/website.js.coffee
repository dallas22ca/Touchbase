@signedInEveryPage = ->
  window.editor = CodeMirror.fromTextArea $("#document_body")[0], 
    matchBrackets: true
    smartIndent: true
    lineWrapping: true
    lineNumbers: true
    theme: "lesser-dark"
    mode: "css"

  $(".nav:not(.social)").sortable
    placeholder: "drop_placeholder"
    start: (e, ui) ->
      html = $(ui.item).html()
      $(".drop_placeholder").append html
    update: (e, ui) ->
      id = $(this).data("page-id")
      $.post $("body").data("save_path"),
        page_id: $("body").data("page_id")
        pages: $(this).sortable("toArray")
        path: $("body").data("path")

  $(".draggable_menu .option").draggable
    connectToSortable: ".drop_area"
    helper: "clone"
    start: (e, ui) ->
      # html = $(ui.helper).html()
      # $(".drop_placeholder").append(html).addClass($(ui.helper).attr("class"))
      # $(ui.item).addClass("drop_helper")
      $(".draggable_menu").hide 150
      $("body").addClass "dragging"

  $(".drop_area").sortable
    items: ".drop_item"
    connectWith: ".drop_area"
    placeholder: "drop_placeholder"
    helper: "drop_helper"
    handle: ".drop_handle"
    cancel: "[contenteditable]"
    start: (e, ui) ->
      if ui.item.hasClass "draggable"
        type = ui.item.data("type")
        template = $("#templates .#{type}").clone()
        $(".editable_placeholder").append template
        $(ui.item).addClass("editable_helper")
      else
        html = $(ui.item).html()
        $(".drop_placeholder").append(html).addClass(ui.item.attr("class"))
        $(ui.item).addClass("drop_helper")
    stop: (e, ui) ->
      ui.item.removeClass("drop_helper")
      type = ui.item.data("type")

      if ui.item.hasClass "draggable"
        console.log "draggable"
      
      $("body").removeClass "dragging"
      createSnapshot()

signedIn = ->
  $(document).on "click", ".show_new_page", ->
    if $("#new_page").is(":visible")
      $("#new_page, .edit_page").hide 150
    else
      $("#new_page").show 150
      $(".edit_page").hide 150
      
      $("html, body").animate
        scrollTop: 0
      , 300

    false
    
  $(document).on "click", ".show_edit_page", ->
    if $(".edit_page").is(":visible")
      $("#new_page, .edit_page").hide 150
    else
      $("#new_page").hide 150
      $(".edit_page").show 150
      
      $("html, body").animate
        scrollTop: 0
      , 300

    false
  
  $(document).on "click", "html, body", (e) ->
    if !$(e.target).parents(".editable").length
      $("[contenteditable]").removeAttr "contenteditable"

  $(document).on "click", ".contenteditable", ->
    $(this).attr "contenteditable", true
    $(this).focus()
  
  $(document).on "click", ".show_draggable_menu", ->
    type = $(this).data("type")
    $(".draggable_menu[data-type='#{type}']").toggle 150
    false
  
  $(document).on "click", ".edit_layout_file", ->
    if $(".edit_document").is(":visible")
      $(".edit_document").hide 150
      $("body, html").css "overflow", "auto"
    else
      $(".edit_document").show 150
      
      setTimeout ->
        window.editor.refresh()
      , 0
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
  
  $(document).on "click", ".drop_delete", ->
    $(this).parent().remove()
    createSnapshot()
    false

  $(document).on
    mouseenter: ->
      if !$(".drop_placeholder").length && !$("*:focus").length
        handle = $("<i>").addClass("icon-move drop_handle")
        trash = $("<i>").addClass("icon-trash drop_delete")
        handle.css("width", $(this).width())
        handle.prependTo $(this)
        trash.prependTo $(this)
    mouseleave: ->
      if !$(".drop_placeholder").length
        $(".drop_handle, .drop_delete").remove()
    click: ->
      $(".drop_handle, .drop_delete").remove()
  , ".drop_item"

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