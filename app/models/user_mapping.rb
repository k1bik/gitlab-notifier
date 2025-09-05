class UserMapping < ApplicationRecord
  before_validation :strip_whitespace, on: :create

  validates :email, :slack_user_id, :slack_channel_id, presence: true, uniqueness: { case_sensitive: false }

  private

  def strip_whitespace
    attributes.each do |key, value|
      if value.is_a?(String)
        self[key] = value.strip
      end
    end
  end
end
