class Step < ApplicationRecord
  belongs_to :quest

  validates :description, presence: true
  validates :position, presence: true
end
