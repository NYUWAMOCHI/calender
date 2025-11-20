# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:mock_google_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:fixed_time) { Time.zone.parse('2025-11-21 10:00:00') }

  before do
    allow(user).to receive_messages(google_calendar_service: mock_google_service, google_token_expired?: false)
    travel_to(fixed_time)
  end

  describe '#initialize' do
    it 'ユーザーとGoogleカレンダーサービスで初期化される' do
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

    context 'サービスが利用可能な場合' do
      it 'Google Calendarからイベントを取得する' do
        allow(mock_google_service).to receive(:list_events).with(
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

      it 'イベントが見つからない場合は空の配列を返す' do
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: nil)
        )

        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([])
      end

      it 'カスタムcalendar_idを受け付ける' do
        custom_calendar_id = 'custom@example.com'
        allow(mock_google_service).to receive(:list_events).with(
          custom_calendar_id,
          hash_including(time_min: time_min, time_max: time_max)
        ).and_return(google_list_result)

        events = service.fetch_events(time_min, time_max, custom_calendar_id)
        expect(events).to eq([google_event])
      end
    end

    context 'Google APIエラーが発生した場合' do
      it '空の配列を返しエラーをログに記録する' do
        error = Google::Apis::ClientError.new('API Error')
        allow(mock_google_service).to receive(:list_events).and_raise(error)
        allow(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        events = service.fetch_events(time_min, time_max)
        expect(events).to eq([])
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it '空の配列を返す' do
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

    it '変換されたフォーマットでビジー時間を返す' do
      busy_times = service.fetch_busy_times(time_min, time_max)

      expect(busy_times).to be_an(Array)
      expect(busy_times[0]).to include(
        start: time_min,
        end: time_max,
        summary: 'Test Event',
        transparent: false
      )
    end

    it '透明イベントを正しくマークする' do
      google_event.transparency = 'transparent'
      busy_times = service.fetch_busy_times(time_min, time_max)

      expect(busy_times[0][:transparent]).to be true
    end

    it '日付フィールドを持つ終日イベントを処理する' do
      all_day_event = Google::Apis::CalendarV3::Event.new(
        id: 'event_2',
        summary: 'All Day Event',
        start: Google::Apis::CalendarV3::EventDateTime.new(date: Time.zone.today),
        end: Google::Apis::CalendarV3::EventDateTime.new(date: Time.zone.today + 1.day),
        transparency: 'opaque'
      )
      allow(service).to receive(:fetch_events).and_return([all_day_event])

      busy_times = service.fetch_busy_times(time_min, time_max)
      expect(busy_times[0][:start]).to eq(Time.zone.today)
      expect(busy_times[0][:end]).to eq(Time.zone.today + 1.day)
    end
  end

  describe '#accessible?' do
    context 'サービスが利用可能でトークンが有効期限内の場合' do
      it 'trueを返す' do
        expect(service.accessible?).to be true
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'falseを返す' do
        expect(service.accessible?).to be false
      end
    end

    context 'トークンが期限切れの場合' do
      before do
        allow(user).to receive(:google_token_expired?).and_return(true)
      end

      it 'falseを返す' do
        expect(service.accessible?).to be false
      end
    end
  end
end
