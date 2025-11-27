class RocketsController < ApplicationController
  def index
    action = RocketsIndexAction.new(filters: index_filters)

    render json: action.call
  end

  def show
    action = RocketsShowAction.new(rocket_id: params[:id])

    render json: action.call
  end

  private

  def index_filters
    {
      speed_above: params[:speed_above].to_i,
      speed_under: params[:speed_under].to_i,
      sort: params[:sort],
      status: params[:status],
      mission: params[:mission],
      rocket_type: params[:rocket_type],
      page: Integer(params[:page], exception: false),
      per_page: Integer(params[:per_page], exception: false)
    }.compact_blank
  end
end
