class Quest < ApplicationRecord
  belongs_to :user
  belongs_to :room

  has_many :steps, -> { order(:position) }, dependent: :destroy
  has_many :lantern_events, dependent: :destroy

  accepts_nested_attributes_for :steps

  validates :title, presence: true

  def completed?
    steps.any? && steps.all?(&:done?)
  end
end
