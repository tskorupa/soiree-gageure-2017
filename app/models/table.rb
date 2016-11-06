class Table < ApplicationRecord
  belongs_to :lottery

  attr_readonly :lottery_id

  validates :number, :capacity, numericality: { only_integer: true, greater_than: 0 }
  validates_uniqueness_of :number, scope: :lottery_id
end
