jQuery(document).on 'turbolinks:load', ->
  fullscreen_button = $('[data-fullscreen]')
  if fullscreen_button.length > 0
    timeout = null;
    fullscreen_button.hide()

    $(document).mousemove ->
      clearTimeout(timeout)
      fullscreen_button.show()
      timeout = setTimeout(
         -> fullscreen_button.fadeOut(),
        3000
      )

    fullscreen_button.click ->
      menus = $('.navbar, .sidebar')
      menus.toggle()

      $('.main').toggleClass('col-sm-10 col-sm-offset-2 fullscreen')

      text = if menus.is(':visible')
        fullscreen_button.data('go-fullscreen-message')
      else
        fullscreen_button.data('return-from-fullscreen-message')
      fullscreen_button.find('a').text(text)

      return false
