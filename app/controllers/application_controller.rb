class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  def handle_not_found(error)
    render json: { error: error.message }, status: :not_found
  end
end
