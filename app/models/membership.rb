class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group, class_name: 'Group'

  enum role: { pl: 0, kp: 1 }

  validates :user_id, uniqueness: { scope: :group_id }
end
