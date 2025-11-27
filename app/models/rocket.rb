class Rocket < ApplicationRecord
  has_many :rocket_messages, dependent: :destroy
end
