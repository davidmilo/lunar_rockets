module RocketMessages
  class RocketSpeedDecreased < RocketMessage
    store_accessor :message, :by

    validates :by, presence: true, numericality: { only_integer: true }
  end
end
