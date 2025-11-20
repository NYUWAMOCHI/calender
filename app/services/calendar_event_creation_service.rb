# frozen_string_literal: true

# Service for creating events in Google Calendar
# Used when a confirmed event is ready to be synced to user calendars
class CalendarEventCreationService
  def initialize(user)
    @user = user
    @service = @user.google_calendar_service
  end

  # Create an event in Google Calendar
  def create_event(title, start_time, end_time, calendar_id = 'primary', description = nil)
    return { success: false, error: 'Google Calendar に接続していません' } unless @service

    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: start_time,
        time_zone: 'Asia/Tokyo'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: end_time,
        time_zone: 'Asia/Tokyo'
      ),
      description: description || 'Created by TRPG Calendar'
    )

    result = @service.insert_event(calendar_id, event)
    {
      success: true,
      google_event_id: result.id,
      event: result
    }
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Google Calendar API Error: #{e.message}")
    {
      success: false,
      error: e.message
    }
  end

  # Update an existing event in Google Calendar
  def update_event(google_event_id, title, start_time, end_time, calendar_id = 'primary', description = nil)
    return { success: false, error: 'Google Calendar に接続していません' } unless @service

    event = Google::Apis::CalendarV3::Event.new(
      summary: title,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: start_time,
        time_zone: 'Asia/Tokyo'
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: end_time,
        time_zone: 'Asia/Tokyo'
      ),
      description: description || 'Updated by TRPG Calendar'
    )

    result = @service.update_event(calendar_id, google_event_id, event)
    {
      success: true,
      event: result
    }
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Google Calendar API Error: #{e.message}")
    {
      success: false,
      error: e.message
    }
  end

  # Delete an event from Google Calendar
  def delete_event(google_event_id, calendar_id = 'primary')
    return { success: false, error: 'Google Calendar に接続していません' } unless @service

    @service.delete_event(calendar_id, google_event_id)
    { success: true }
  rescue Google::Apis::ClientError => e
    Rails.logger.error("Google Calendar API Error: #{e.message}")
    {
      success: false,
      error: e.message
    }
  end
end
