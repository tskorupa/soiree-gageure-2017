# frozen_string_literal: true

class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table(:guests) do |t|
      t.string(:full_name, null: false)
    end

    create_table(:sellers) do |t|
      t.string(:full_name, null: false)
    end

    create_table(:lotteries) do |t|
      t.date(:event_date, null: false)
      t.decimal(:meal_voucher_price, precision: 6, scale: 2)
      t.decimal(:ticket_price, precision: 6, scale: 2)

      t.timestamps(null: false)
    end

    create_table(:prizes) do |t|
      t.belongs_to(:lottery, null: false, index: true)

      t.integer(:draw_order, null: false)
      t.decimal(:amount, null: false, precision: 6, scale: 2)

      t.timestamps(null: false)
    end

    create_table(:tables) do |t|
      t.belongs_to(:lottery, null: false, index: true)

      t.integer(:number, null: false)
      t.integer(:capacity, null: false)

      t.timestamps(null: false)
    end
    add_index(:tables, %i(lottery_id number), unique: true)

    create_table(:tickets) do |t|
      t.belongs_to(:lottery, null: false, index: true)
      t.belongs_to(:seller, null: false, index: true)
      t.belongs_to(:guest, null: false, index: true)

      t.integer(:number, null: false)

      t.timestamps(null: false)
    end
    add_index(:tickets, %i(lottery_id number), unique: true)
  end
end
