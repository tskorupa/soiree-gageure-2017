jQuery(document).on 'turbolinks:load', ->
  drawn_ticket = $('#drawn-ticket')
  if drawn_ticket.length > 0
    App.cable.subscriptions.create {
        channel: 'DrawnTicketChannel',
        lottery_id: drawn_ticket.data('lottery-id')
      },
      received: (data) ->
        $('#drawn-ticket').replaceWith(data.message)
