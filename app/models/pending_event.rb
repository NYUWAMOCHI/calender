class PendingEvent < ApplicationRecord
  belongs_to :group
  belongs_to :scenario
  has_many :approvals, dependent: :destroy
  has_many :approved_users, through: :approvals, source: :user

  validates :group_id, uniqueness: true
  validates :start_time, :end_time, presence: true

  # Check if all members have approved
  def all_approved?
    group_members_count = group.members.count
    approvals.where(approved: true).count == group_members_count
  end

  # Get approval status for display
  def approval_status
    {
      total: group.members.count,
      approved: approvals.where(approved: true).count,
      pending: approvals.where(approved: false).count
    }
  end
end
