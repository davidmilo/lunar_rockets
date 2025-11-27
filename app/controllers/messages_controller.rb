class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    action = MessagesCreateAction.new(params: message_params)
    action.call

    render json: {}, status: :created
  end

  private

  def message_params
    params.permit(
      :format,
      metadata: %i[channel messageNumber messageTime messageType],
      message: %i[type launchSpeed mission by reason newMission],
    )
  end
end
