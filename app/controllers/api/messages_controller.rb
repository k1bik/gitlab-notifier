module Api
  class MessagesController < ApplicationController
    def create
      if params[:email].blank? || params[:message].blank?
        render json: { error: "Email and message are required" }, status: :unprocessable_entity
        return
      end

      user_mapping = UserMapping.find_by(email: params[:email])

      if user_mapping.blank?
        render json: { error: "User not found" }, status: :not_found
        return
      end

      Slack::SendDmMessageJob.perform_async(user_mapping.slack_channel_id, params[:message])

      render json: { message: "Message sent" }, status: :created
    end
  end
end
