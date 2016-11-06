class Ticket < ApplicationRecord
  belongs_to :lottery
  belongs_to :seller
  belongs_to :guest, optional: true
  belongs_to :sponsor, optional: true

  attr_readonly :lottery_id

  validates :number, numericality: { only_integer: true, greater_than: 0 }, uniqueness: { scope: :lottery_id }
end
