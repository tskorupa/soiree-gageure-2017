class Table < ApplicationRecord
  belongs_to :lottery

  validates :number, :capacity, numericality: { only_integer: true, greater_than: 0 }
  validates_uniqueness_of :number, scope: :lottery_id
end
