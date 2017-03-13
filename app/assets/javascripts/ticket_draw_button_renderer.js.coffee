jQuery(document).on 'turbolinks:load', ->
  draw_buttons = $('[data-draw-ticket-id]')
  instructions = $('[data-ticket-draw-instructions]')
  if draw_buttons.length == 1
    draw_buttons.show()
    instructions.hide()
  else
    draw_buttons.hide()
    instructions.show()
