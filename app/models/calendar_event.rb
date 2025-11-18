class CalendarEvent < ApplicationRecord
  belongs_to :user

  validates :title, :start_time, :end_time, presence: true

  # Soft delete scope
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :included_in_availability, -> { where(included_in_availability: true) }

  # Check if event is deleted
  def deleted?
    deleted_at.present?
  end

  # Restore a deleted event
  def restore
    update(deleted_at: nil)
  end

  # Exclude from availability calculation
  def exclude
    update(included_in_availability: false)
  end

  # Include in availability calculation
  def include_in_availability
    update(included_in_availability: true)
  end
end
