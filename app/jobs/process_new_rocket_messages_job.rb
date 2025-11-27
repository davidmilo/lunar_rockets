class ProcessNewRocketMessagesJob < ApplicationJob
  queue_as :default

  def perform(rocket_id:)
    ProcessNewRocketMessages.call(rocket_id: rocket_id)
  end
end
