class EstimationItem < ApplicationRecord
  validates :reference_url, presence: true

  before_validation :strip_whitespace, on: :create

  has_many :estimations, dependent: :destroy

  private

  def strip_whitespace
    self.reference_url = reference_url.strip
  end
end
