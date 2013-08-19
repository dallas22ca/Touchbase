$(document).on "click", ".toggle_change_password", ->
  $(".change_password").toggle 150, ->
    $(this).siblings(".change_password").find("input:first").focus() if $(window).width() > 720
  false