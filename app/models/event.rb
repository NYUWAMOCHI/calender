class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :title, presence: true, length: { maximum: 20 }
  validates :description, length: { maximum: 3000 }, allow_blank: true
  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    errors.add(:end_time, 'must be after the start time') if end_time < start_time
  end
end
