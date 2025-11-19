class Approval < ApplicationRecord
  belongs_to :pending_event
  belongs_to :user

  validates :pending_event_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :pending_event_id }
  validate :approved_at_required_when_approved

  # Approve the pending event
  def approve
    update(approved: true, approved_at: Time.current)
  end

  # Check if this is auto-created for new member
  def new_member?
    auto_created?
  end

  private

  def approved_at_required_when_approved
    if approved? && approved_at.blank?
      errors.add(:approved_at, 'must be set when approved is true')
    end
  end
end
