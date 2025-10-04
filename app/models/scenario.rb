class Scenario < ApplicationRecord
  belongs_to :user
  has_many :user_scenarios, dependent: :destroy

  validates :scenario_id, uniqueness: true
end
