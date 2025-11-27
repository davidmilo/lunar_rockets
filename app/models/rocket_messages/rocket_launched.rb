module RocketMessages
  class RocketLaunched < RocketMessage
    store_accessor :message, :launchSpeed, :mission

    def rocket_type
      message["type"]
    end

    validates :rocket_type, presence: true
    validates :launchSpeed, presence: true, numericality: { only_integer: true }
    validates :mission, presence: true
  end
end
