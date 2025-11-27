class ProcessRocketMessage
  def self.call(rocket, type, payload)
    case type
    when "RocketMessages::RocketLaunched"
      rocket.status = :launched
      rocket.rocket_type = payload["type"]
      rocket.speed = payload["launchSpeed"].to_i
      rocket.mission = payload["mission"]
    when "RocketMessages::RocketSpeedIncreased"
      rocket.speed += payload["by"].to_i
    when "RocketMessages::RocketSpeedDecreased"
      rocket.speed -= payload["by"].to_i
    when "RocketMessages::RocketMissionChanged"
      rocket.mission = payload["newMission"]
    when "RocketMessages::RocketExploded"
      rocket.status = :exploded
      rocket.accident = payload["reason"]
    else
      raise "Unknown message type: #{type}"
    end
  end
end
