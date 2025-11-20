# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:mock_google_service) { instance_double('Google::Apis::CalendarV3::CalendarService') }
  let(:fixed_time) { Time.zone.parse('2025-11-21 10:00:00') }

  before do
    allow(user).to receive(:google_calendar_service).and_return(mock_google_service)
    allow(user).to receive(:google_token_expired?).and_return(false)
    travel_to(fixed_time)
  end

  after do
    travel_back
  end

  describe '#initialize' do
    it 'initializes with user and google calendar service' do
      expect(service.instance_variable_get(:@user)).to eq(user)
      expect(service.instance_variable_get(:@service)).to eq(mock_google_service)
    end
  end

  describe '#fetch_events' do
    let(:time_min) { 1.day.ago }
    let(:time_max) { 1.day.from_now }
    let(:google_event) do
      Google::Apis::CalendarV3::Event.new(
        id: 'event_1',
        summary: 'Test Event',
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: time_min),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: time_max),
        transparency: 'opaque',
        description: 'Test Description'
      )
    end
    let(:google_list_result) do
      Google::Apis::CalendarV3::Events.new(items: [google_event])
    end

    context 'when service is available' do
      it 'fetches events from Google Calendar' do
        expect(mock_google_service).to receive(:list_events).with(
          'primary',
          time_min: time_min,
          time_max: time_max,
          single_events: true,
          order_by: 'startTime',
          fields: 'items(id, summary, start, end, transparency, description)'
        ).and_return(google_list_result)

        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([google_event])
      end

      it 'returns empty array when no events found' do
        expect(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: nil)
        )

        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([])
      end

      it 'accepts custom calendar_id' do
        custom_calendar_id = 'custom@example.com'
        expect(mock_google_service).to receive(:list_events).with(
          custom_calendar_id,
          hash_including(time_min: time_min, time_max: time_max)
        ).and_return(google_list_result)

        service.fetch_events(time_min, time_max, custom_calendar_id)
      end
    end

    context 'when Google API error occurs' do
      it 'returns empty array and logs error' do
        error = Google::Apis::ClientError.new('API Error')
        expect(mock_google_service).to receive(:list_events).and_raise(error)
        expect(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([])
      end
    end

    context 'when service is not available' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'returns empty array' do
        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([])
      end
    end
  end

  describe '#fetch_busy_times' do
    let(:time_min) { 1.day.ago }
    let(:time_max) { 1.day.from_now }
    let(:google_event) do
      Google::Apis::CalendarV3::Event.new(
        id: 'event_1',
        summary: 'Test Event',
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: time_min),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: time_max),
        transparency: 'opaque'
      )
    end

    before do
      allow(service).to receive(:fetch_events).and_return([google_event])
    end

    it 'returns busy times with transformed format' do
      busy_times = service.fetch_busy_times(time_min, time_max)

      expect(busy_times).to be_an(Array)
      expect(busy_times[0]).to include(
        start: time_min,
        end: time_max,
        summary: 'Test Event',
        transparent: false
      )
    end

    it 'marks transparent events correctly' do
      google_event.transparency = 'transparent'
      busy_times = service.fetch_busy_times(time_min, time_max)

      expect(busy_times[0][:transparent]).to be true
    end

    it 'handles all-day events with date fields' do
      all_day_event = Google::Apis::CalendarV3::Event.new(
        id: 'event_2',
        summary: 'All Day Event',
        start: Google::Apis::CalendarV3::EventDateTime.new(date: Date.today),
        end: Google::Apis::CalendarV3::EventDateTime.new(date: Date.tomorrow),
        transparency: 'opaque'
      )
      allow(service).to receive(:fetch_events).and_return([all_day_event])

      busy_times = service.fetch_busy_times(time_min, time_max)
      expect(busy_times[0][:start]).to eq(Date.today)
      expect(busy_times[0][:end]).to eq(Date.tomorrow)
    end
  end

  describe '#accessible?' do
    context 'when service is available and token is not expired' do
      it 'returns true' do
        expect(service.accessible?).to be true
      end
    end

    context 'when service is not available' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'returns false' do
        expect(service.accessible?).to be false
      end
    end

    context 'when token is expired' do
      before do
        allow(user).to receive(:google_token_expired?).and_return(true)
      end

      it 'returns false' do
        expect(service.accessible?).to be false
      end
    end
  end
end
