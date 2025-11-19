# frozen_string_literal: true

# Service for synchronizing Google Calendar events with CalendarEvent records
# Handles one-way sync from Google Calendar to app database
class CalendarSyncService
  def initialize(user)
    @user = user
    @service = @user.google_calendar_service
  end

  # Sync calendar events from Google Calendar to database
  # Fetches events from past 30 days to 1 year in future
  # Returns hash with success status and sync count
  def sync_calendar
    return { success: false, error: 'Google Calendar に接続していません' } unless @service

    begin
      google_events = fetch_google_events
      sync_events(google_events)

      {
        success: true,
        message: "#{google_events.length}件のイベントを同期しました",
        synced_count: google_events.length
      }
    rescue Google::Apis::ClientError => e
      Rails.logger.error("Calendar sync error: #{e.message}")
      {
        success: false,
        error: "Google Calendar との同期に失敗しました: #{e.message}"
      }
    end
  end

  private

  # Fetch events from Google Calendar (past 30 days to 1 year future)
  def fetch_google_events
    time_min = 30.days.ago.rfc3339
    time_max = 1.year.from_now.rfc3339

    result = @service.list_events(
      'primary',
      time_min: time_min,
      time_max: time_max,
      single_events: true,
      order_by: 'startTime',
      fields: 'items(id, summary, start, end, description)'
    )

    result.items || []
  end

  # Sync Google Calendar events with CalendarEvent records
  # - New events: INSERT
  # - Existing events: UPDATE
  # - Deleted events: DELETE (hard delete)
  def sync_events(google_events)
    google_event_ids = Set.new(google_events.map(&:id))
    existing_event_ids = @user.calendar_events.pluck(:google_event_id).to_set

    # Sync new and updated events
    google_events.each do |google_event|
      calendar_event = @user.calendar_events.find_or_initialize_by(
        google_event_id: google_event.id
      )

      calendar_event.assign_attributes(
        title: google_event.summary || 'No Title',
        start_time: google_event.start.date_time || google_event.start.date,
        end_time: google_event.end.date_time || google_event.end.date,
        description: google_event.description,
        google_calendar_id: 'primary',
        synced_at: Time.current,
        deleted_at: nil  # Restore if previously deleted
      )

      calendar_event.save
    end

    # Hard delete events that were deleted in Google Calendar
    deleted_event_ids = existing_event_ids - google_event_ids
    @user.calendar_events
      .where(google_event_id: deleted_event_ids)
      .where(deleted_at: nil)
      .delete_all if deleted_event_ids.any?
  end
end
