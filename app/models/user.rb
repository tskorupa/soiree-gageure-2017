class User < ApplicationRecord
  devise(:database_authenticatable)
  validates(:email, presence: true, uniqueness: true)
  with_options(presence: true, length: { minimum: 3 }) do |assoc|
    assoc.validates(:password, on: :create)
    assoc.validates(:password, on: :update, allow_blank: true)
  end
end
