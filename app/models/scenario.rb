class Scenario < ApplicationRecord
  belongs_to :group
  has_many :pending_events, dependent: :destroy
  has_many :confirmed_events, dependent: :destroy

  validates :name, presence: true
end
