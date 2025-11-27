class RocketPresenter
  def initialize(rocket:, options: {})
    @rocket = rocket
    @options = options
  end

  def as_json
    result = {
      id: rocket.id,
      uuid: rocket.uuid,
      status: rocket.status,
      rocket_type: rocket.rocket_type,
      speed: rocket.speed,
      mission: rocket.mission,
      accident: rocket.accident,
      last_processed_message_number: rocket.last_processed_message_number,
      last_processed_message_at: rocket.last_processed_message_at
    }

    result.merge!(unprocessed_message_count: unprocessed_message_count) if show_unprocessed_message_count?

    result
  end

  private

  attr_reader :rocket, :options

  def unprocessed_message_count
    rocket.rocket_messages.where("number > ?", rocket.last_processed_message_number || 0).count
  end

  def show_unprocessed_message_count?
    options[:show_unprocessed_message_count].presence
  end
end
