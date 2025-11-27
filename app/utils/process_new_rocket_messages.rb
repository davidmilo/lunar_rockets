class ProcessNewRocketMessages
  def self.call(rocket_id:)
    Rocket.transaction do
      rocket = Rocket.lock.find(rocket_id)

      last = rocket.last_processed_message_number || 0
      messages = rocket.rocket_messages
                      .where("number > ?", last)
                      .order(:number)

      expected = last + 1

      messages.each do |message|
        break if message.number != expected

        ProcessRocketMessage.call(rocket, message.type, message.message)
        rocket.last_processed_message_number = message.number
        rocket.last_processed_message_at = Time.zone.now
        expected += 1
      end

      rocket.save!
    end
  end
end
