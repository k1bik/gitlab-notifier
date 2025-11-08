module Slack
  class SendDmMessageJob
    include Sidekiq::Job
    sidekiq_options retry: 3

    def perform(slack_channel_id, text = nil, blocks = [])
      return if text.blank? && blocks.blank?

      Service.new.send_message(slack_channel_id, text, blocks)
    end
  end
end
