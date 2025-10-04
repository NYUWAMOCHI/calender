class UserScenario < ApplicationRecord
  belongs_to :user
  belongs_to :scenario

  validates :status, inclusion: { in: %w[played want_to_play completed] }
  validates :user_id, uniqueness: { scope: :scenario_id }
end
