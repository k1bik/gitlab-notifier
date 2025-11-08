module Slack
  class SendDmMessageJob
    include Sidekiq::Job
    sidekiq_options retry: 3

    def perform(email, text = nil, blocks = [])
      return if text.blank? && blocks.blank?

      user_mapping = UserMapping.find_by(email:)

      return if user_mapping.blank?

      Service.new.send_message(user_mapping.slack_channel_id, text, blocks)
    end
  end
end
