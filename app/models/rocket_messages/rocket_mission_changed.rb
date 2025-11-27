module RocketMessages
  class RocketMissionChanged < RocketMessage
    store_accessor :message, :newMission

    validates :newMission, presence: true
  end
end
