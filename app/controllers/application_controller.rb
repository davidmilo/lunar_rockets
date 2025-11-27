class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from StandardError, with: :render_internal_error
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_not_found(exception)
    render json: {
      error: "not_found",
      message: exception.message
    }, status: :not_found
  end

  def render_bad_request(exception)
    render json: {
      error: "bad_request",
      message: exception.message
    }, status: :bad_request
  end

  def render_unprocessable_entity(exception)
    render json: {
      error: "unprocessable_entity",
      message: exception.record.errors.full_messages.join(", ")
    }, status: :unprocessable_entity
  end

  def render_internal_error(exception)
    Rails.logger.error("#{exception.class}: #{exception.message}")
    Rails.logger.error(exception.backtrace.join("\n")) if Rails.env.development?

    render json: {
      error: "internal_server_error",
      message: "An unexpected error occurred"
    }, status: :internal_server_error
  end  
end
