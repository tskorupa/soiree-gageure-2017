class TicketPdf
  WIDTH = 175.748
  HEIGHT = 79.3701

  def initialize(ticket:)
    @ticket = ticket
  end

  def filename
    format(
      '%s_%i.pdf',
      Ticket.model_name.human.downcase,
      ticket.number,
    )
  end

  def render
    Prawn::Font::AFM.hide_m17n_warning = true
    pdf = Prawn::Document.new(margin: 0, page_size: [WIDTH, HEIGHT])
    pdf.bounding_box([0, pdf.cursor], width: WIDTH, height: HEIGHT) do
      pdf.move_down(8)
      pdf.text(
        ticket.guest.full_name,
        overflow: :skrink_to_fit,
        style: :bold,
        size: 15,
        align: :center,
      )

      pdf.formatted_text(
        [
          { text: padded_ticket_number, size: 32 },
          { text: "   " },
          { text: table_number, size: 12 },
        ],
        align: :center,
        valign: :bottom,
      )
    end
    pdf.render
  end

  private

  attr_reader :ticket

  def padded_ticket_number
    PaddedNumber.pad_number(ticket.number)
  end

  def table_number
    format(
      '%s %i',
      Table.model_name.human.downcase,
      ticket.table.number,
    )
  end
end
