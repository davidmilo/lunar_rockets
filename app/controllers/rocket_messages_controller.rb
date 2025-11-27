class RocketMessagesController < ApplicationController
  def index
    action = RocketMessagesIndexAction.new(rocket_id: params[:rocket_id], filters: index_filters)

   render json: action.call
  end

  private

  def index_filters
    {
      page: Integer(params[:page], exception: false),
      per_page: Integer(params[:per_page], exception: false)
    }.compact_blank
  end
end
