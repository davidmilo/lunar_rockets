module RocketMessages
  class RocketExploded < RocketMessage
     store_accessor :message, :reason

     validates :reason, presence: true
  end
end
