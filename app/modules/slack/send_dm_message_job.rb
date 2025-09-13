module Slack
  class SendDmMessageJob
    include Sidekiq::Job
    sidekiq_options retry: 3

    def perform(email, text)
      user_mapping = UserMapping.find_by(email:)

      return if user_mapping.blank?

      Service.new.send_dm(user_mapping, text)
    end
  end
end
