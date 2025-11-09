class Availability < ApplicationRecord
  belongs_to :user

  validates :source, inclusion: { in: %w[manual google_calendar] }
  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    errors.add(:end_time, 'must be after the start time') if end_time < start_time
  end
end
