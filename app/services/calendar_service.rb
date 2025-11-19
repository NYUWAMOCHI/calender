# frozen_string_literal: true

# Service for interacting with Google Calendar API
# Handles fetching events and querying availability information
class CalendarService
  def initialize(user)
    @user = user
    @service = @user.google_calendar_service
  end

  # Fetch events from Google Calendar within a time range
  def fetch_events(time_min, time_max, calendar_id = 'primary')
    return [] unless @service

    result = @service.list_events(
      calendar_id,
      time_min: time_min,
      time_max: time_max,
      single_events: true,
      order_by: 'startTime',
      fields: 'items(id, summary, start, end, transparency, description)'
    )

    result.items || []
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Google Calendar API Error: #{e.message}")
    []
  end

  # Fetch busy times from Google Calendar
  # Returns array of events with start/end times and transparency info
  def fetch_busy_times(time_min, time_max, calendar_id = 'primary')
    events = fetch_events(time_min, time_max, calendar_id)

    events.map do |event|
      {
        start: event.start.date_time || event.start.date,
        end: event.end.date_time || event.end.date,
        summary: event.summary,
        transparent: event.transparency == 'transparent'
      }
    end
  end

  # Check if user can access Google Calendar
  def accessible?
    @service.present? && !@user.google_token_expired?
  end
end
