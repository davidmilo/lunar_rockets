class MessagesCreateAction
  def initialize(params:)
    @params = params
  end

  def call
    find_or_create_rocket_message

    ProcessNewRocketMessagesJob.perform_later(rocket_id: rocket.id)
  end

  private

  attr_reader :params

  def rocket
    @rocket ||= find_or_create_rocket
  end

  def find_or_create_rocket
    return Rocket.create_or_find_by!(uuid: params.dig(:metadata, :channel)) if params[:metadata][:messageType] == "RocketLaunched"

    Rocket.find_by!(uuid: params.dig(:metadata, :channel))
  end

  def find_or_create_rocket_message
    message_type = "RocketMessages::#{params.dig(:metadata, :messageType)}"
    rocket_message = rocket.rocket_messages.find_or_initialize_by(number: params.dig(:metadata, :messageNumber), type: message_type)
    rocket_message.message = params[:message]
    rocket_message.time    = params.dig(:metadata, :messageTime)
    rocket_message.save!
  end
end
