class TemporaryDeploymentNotificationTarget < ApplicationRecord
  validates :environment, :slack_channel_id, presence: true

  before_validation :strip_whitespace, on: :create

  private

  def strip_whitespace
    attributes.each do |key, value|
      if value.is_a?(String)
        self[key] = value.strip
      end
    end
  end
end
