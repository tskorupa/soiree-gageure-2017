# frozen_string_literal: true

class AddFullTextSearchIndicesOnSellersAndGuestsAndSponsors < ActiveRecord::Migration[5.0]
  def up
    execute("CREATE INDEX full_text_en_on_sellers ON sellers USING gin(to_tsvector('english', 'full_name'));")
    execute("CREATE INDEX full_text_en_on_guests ON guests USING gin(to_tsvector('english', 'full_name'));")
    execute("CREATE INDEX full_text_en_on_sponsors ON sponsors USING gin(to_tsvector('english', 'full_name'));")
  end

  def down
    execute('DROP INDEX full_text_en_on_sellers')
    execute('DROP INDEX full_text_en_on_guests')
    execute('DROP INDEX full_text_en_on_sponsors')
  end
end
