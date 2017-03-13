jQuery(document).on 'turbolinks:load', ->
  return_to_draw_buttons = $('[data-drawn-position]')
  return_to_draw_buttons.hide()
  return_to_draw_buttons.last().show()
