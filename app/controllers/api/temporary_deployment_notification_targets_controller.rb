module Api
  class TemporaryDeploymentNotificationTargetsController < ApplicationController
    def create
      environment = params[:environment]
      user_email = params[:user_email]
      slack_channel_id = params[:slack_channel_id]

      return render_error("Environment is required") if environment.blank?
      return render_error("User email or Slack channel ID are required") if user_email.blank? && slack_channel_id.blank?
      return render_error("Only one of User email or Slack channel ID is required") if user_email.present? && slack_channel_id.present?

      slack_channel_id ||= UserMapping.find_by!(email: user_email).slack_channel_id

      TemporaryDeploymentNotificationTarget.create!(environment:, slack_channel_id:)

      render json: { message: "Temporary deployment notification target created" }, status: :created
    end

    private

    def render_error(message)
      render json: { error: message }, status: :unprocessable_entity
    end
  end
end
