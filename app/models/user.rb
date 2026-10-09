class User < ApplicationRecord
  devise :magic_link_authenticatable, :registerable, :rememberable

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  has_many :quests
  has_many :lantern_events
end
