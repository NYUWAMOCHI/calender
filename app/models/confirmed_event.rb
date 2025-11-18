class ConfirmedEvent < ApplicationRecord
  belongs_to :group
  belongs_to :scenario

  validates :start_time, :end_time, presence: true

  # Get event title for Google Calendar
  def google_calendar_title
    "【#{group.name}】#{scenario.name}"
  end
end
