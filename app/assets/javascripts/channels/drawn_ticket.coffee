$(document).ready ->
  drawn_ticket = $('#drawn-ticket')
  if drawn_ticket.length > 0
    App.cable.subscriptions.create {
        channel: 'DrawnTicketChannel',
        lottery_id: drawn_ticket.data('lottery-id')
      },
      received: (data) ->
        console.log(data.message)
        $('#drawn-ticket').replaceWith(data.message)
