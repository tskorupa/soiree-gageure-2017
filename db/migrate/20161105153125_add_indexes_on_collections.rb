# frozen_string_literal: true

class AddIndexesOnCollections < ActiveRecord::Migration[5.0]
  def change
    add_index(:sponsors, :full_name, order: { full_name: :asc })
    add_index(:guests, :full_name, order: { full_name: :asc })
    add_index(:sellers, :full_name, order: { full_name: :asc })

    add_index(:lotteries, :event_date, order: { event_date: :desc })

    add_index(:tickets, :number, order: { number: :asc })
    add_index(:tables, :number, order: { number: :asc })

    add_index(:prizes, :draw_order, order: { draw_order: :asc })
  end
end
