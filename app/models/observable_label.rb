class ObservableLabel < ApplicationRecord
  before_validation :strip_whitespace, on: :create

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  private

  def strip_whitespace
    self.name = name.strip
  end
end
