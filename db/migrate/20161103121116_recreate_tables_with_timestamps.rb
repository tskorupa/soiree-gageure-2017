# frozen_string_literal: true

class RecreateTablesWithTimestamps < ActiveRecord::Migration[5.0]
  def up
    drop_table :sellers
    drop_table :guests

    create_table(:sellers) do |t|
      t.string(:full_name, null: false)
      t.timestamps(null: false)
    end
    create_table(:guests) do |t|
      t.string(:full_name, null: false)
      t.timestamps(null: false)
    end
  end
end
