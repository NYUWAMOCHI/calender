class Group < ApplicationRecord
  belongs_to :user  # KP
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :scenarios, dependent: :destroy
  has_many :pending_events, dependent: :destroy
  has_many :confirmed_events, dependent: :destroy
  has_many :profiles, dependent: :destroy

  validates :name, presence: true
  validates :planned_period_start, :planned_period_end, presence: true
end
