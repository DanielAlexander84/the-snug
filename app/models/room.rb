class Room < ApplicationRecord
  has_many :quests

  validates :name, presence: true

  # There is exactly one Room right now — see PLANNING.md.
  def self.the_one
    first!
  end
end
