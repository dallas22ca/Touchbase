$(document).on "click", ".show_new_note", ->
  $("#new_note").toggle()
  $("#new_note textarea").focus() if $(window).width() > 720
  false