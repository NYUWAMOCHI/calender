class CalendarEvent < ApplicationRecord
  belongs_to :user

  validates :title, :start_time, :end_time, presence: true

  # Soft delete scope
  scope :not_deleted, -> { where(deleted_at: nil) }
  scope :included_in_availability, -> { where(included_in_availability: true) }

  # Time range filtering scope
  scope :in_time_range, ->(start_t, end_t) { where('NOT (end_time <= ? OR start_time >= ?)', start_t, end_t) }

  # Combined scope for availability calculation
  scope :available_for_calculation, ->(start_t, end_t) do
    not_deleted
      .included_in_availability
      .in_time_range(start_t, end_t)
  end

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
