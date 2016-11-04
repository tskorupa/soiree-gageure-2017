class CreateSponsors < ActiveRecord::Migration[5.0]
  def change
    create_table(:sponsors) do |t|
      t.string(:full_name, null: false)
      t.timestamps(null: false)
    end
    add_belongs_to(:tickets, :sponsor, index: true)
  end
end
