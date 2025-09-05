module Slack
  class SendDmMessageJob
    include Sidekiq::Job
    sidekiq_options retry: 3

    def perform(email, text)
      user_mapping = UserMapping.find_by(email:)

      return if user_mapping.blank?

      Service.new.slack_connection.post("chat.postMessage") do |request|
        request.body = { channel: user_mapping.slack_channel_id, text: }.to_json
      end
    end
  end
end
