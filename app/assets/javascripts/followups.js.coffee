$(document).on "change keyup", ".offset_field", ->
  Followup.calcOffset()

@Followup =
  initOffset: ->
    if $("#followup_offset").length
      offset = $("#followup_offset")
      value = parseFloat(offset.val())
      abs = Math.abs(value)
      amount = $("#offset_amount")
      unit = $("#offset_unit")
      word = $("#offset_word")
      recurrence = $("#followup_recurrence")
    
      if value == 0
        word.val "on"
        amount.hide()
        unit.hide()
      else
        amount.show()
        unit.show()
        
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
    
  calcOffset: ->
    if $("#followup_offset").length
      offset = $("#followup_offset")
      amount = $("#offset_amount")
      unit = $("#offset_unit")
      word = $("#offset_word")
      field = $("#followup_field_id")
      recurrence = $("#followup_recurrence")
      value = parseFloat amount.val()
      value = 0 if isNaN value
      
      if unit.val() == "month"
        unit_multiplier = 60 * 60 * 24 * 30
      else if unit.val() == "week"
        unit_multiplier = 60 * 60 * 24 * 7
      else
        unit_multiplier = 60 * 60 * 24
    
      if word.val() == "before" || word.val() == "after"
        if word.val() == "after"
          word_multiplier = 1
        else
          word_multiplier = -1
      
        word.insertAfter unit
        amount.show()
        unit.show()
      
        offset.val value * unit_multiplier * word_multiplier
        recurrence.val 0
    
      else if word.val() == "on"
        word.insertAfter unit
        amount.hide()
        unit.hide()
        field.show()
        offset.val 0
        recurrence.val 0
      else if word.val() == "every"
        word.insertBefore amount
        amount.show()
        unit.show()
        field.hide()
        recurrence.val value * unit_multiplier