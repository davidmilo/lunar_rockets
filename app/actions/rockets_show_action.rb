class RocketsShowAction
  def initialize(rocket_id:)
    @rocket_id = rocket_id
  end

  def call
    rocket = Rocket.find(@rocket_id)

    RocketPresenter.new(rocket:, options: { show_unprocessed_message_count: true }).as_json
  end
end
