jQuery(document).on 'turbolinks:load', ->
  update_buttons = $('[data-update-ticket-id]')
  instructions = $('[data-instructions]')

  num_update_buttons = update_buttons.length
  if num_update_buttons == 1
    update_buttons.show()
    instructions.hide()
  else
    update_buttons.hide()
    if num_update_buttons > 2
      instructions.show()
    else
      instructions.hide()
