module RocketMessages
  class RocketSpeedIncreased < RocketMessage
    store_accessor :message, :by

    validates :by, presence: true, numericality: { only_integer: true }
  end
end
