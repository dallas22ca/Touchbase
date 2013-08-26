$(document).on "change keyup", ".offset_field", ->
  Followup.calc()
  Filters.calc()

@Followup =
  init: ->
    if $("#followup_offset").length
      offset = $("#followup_offset")
      recurrence = $("#followup_recurrence")
      re_val = parseFloat(recurrence.val())
      value = parseFloat(offset.val())
      field = $("#fake_field_id")
      
      if re_val != 0
        abs = Math.abs(re_val)
      else
        abs = Math.abs(value)
      
      amount = $("#offset_amount")
      unit = $("#offset_unit")
      word = $("#offset_word")
      
      if re_val != 0
        word.val "every"
      else if value == 0
        word.val "on"
      else
        if value > 0
          word.val "after"  
        else
          word.val "before"

      if abs / 60 / 60 / 24 / 30 % 1 == 0
        unit.val "month"
        amount.val abs / 60 / 60 / 24 / 30
      else if abs / 60 / 60 / 24 / 7 % 1 == 0
        unit.val "week"
        amount.val abs / 60 / 60 / 24 / 7
      else
        unit.val "day"
        amount.val abs / 60 / 60 / 24
      
      Followup.calc()
    
  calc: ->
    if $("#followup_offset").length
      offset = $("#followup_offset")
      amount = $("#offset_amount")
      unit = $("#offset_unit")
      word = $("#offset_word")
      w = word.val()
      field = $("#fake_field_id")
      recurrence = $("#followup_recurrence")
      start = $("#start")
      value = parseFloat amount.val()
      value = 0 if isNaN value
      
      if unit.val() == "month"
        unit_multiplier = 60 * 60 * 24 * 30
      else if unit.val() == "week"
        unit_multiplier = 60 * 60 * 24 * 7
      else
        unit_multiplier = 60 * 60 * 24
    
      if w == "before" || w == "after"
        if word.val() == "after"
          word_multiplier = 1
        else
          word_multiplier = -1
      
        word.insertAfter unit
        offset.val value * unit_multiplier * word_multiplier
        recurrence.val 0
        $("#followup_field_id").val field.val()
    
      else if w == "on"
        word.insertAfter unit
        offset.val 0
        recurrence.val 0
        $("#followup_field_id").val field.val()

      else if w == "every"
        word.insertBefore amount
        offset.val 0
        recurrence.val value * unit_multiplier
        $("#followup_field_id").val start.val()
        
        if start.val().length
          $(".when_explanation").hide()
        else
          $(".when_explanation").show()
        
        $(".offset_amount").text $("#offset_amount").val()
        $(".offset_unit").text $("#offset_unit").val().toLowerCase()
        
    $(".offset_toggle").hide()
    $(".offset_#{w}").show()