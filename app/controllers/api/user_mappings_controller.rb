module Api
  class UserMappingsController < ApplicationController
    def create
      if (emails = params.dig(:emails)).blank?
        render json: { error: "Emails are required" }, status: :unprocessable_entity
        return
      end

      slack_service = Slack::Service.new

      emails.each do |email|
        user_mapping = UserMapping.find_or_initialize_by(email:)
        user_mapping.slack_user_id = slack_service.find_user_id_by_email(email)
        user_mapping.slack_channel_id = slack_service.open_dm(user_mapping.slack_user_id)
        user_mapping.save!
      end

      render json: { message: "User mappings created" }, status: :created
    end
  end
end
