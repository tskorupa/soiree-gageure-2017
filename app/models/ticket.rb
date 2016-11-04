class Ticket < ApplicationRecord
  belongs_to :lottery
  belongs_to :seller
  belongs_to :guest, optional: true
  belongs_to :sponsor, optional: true

  validates :number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
end
