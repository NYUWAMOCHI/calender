class Approval < ApplicationRecord
  belongs_to :pending_event
  belongs_to :user

  validates :user_id, uniqueness: { scope: :pending_event_id }

  # Approve the pending event
  def approve
    update(approved: true, approved_at: Time.current)
  end

  # Check if this is auto-created for new member
  def new_member?
    auto_created?
  end
end
