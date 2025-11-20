# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarSyncService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:mock_google_service) { instance_double(Google::Apis::CalendarV3::CalendarService) }
  let(:fixed_time) { Time.zone.parse('2025-11-21 10:00:00') }

  before do
    allow(user).to receive(:google_calendar_service).and_return(mock_google_service)
    travel_to(fixed_time)
  end

  describe '#initialize' do
    it 'ユーザーとGoogleカレンダーサービスで初期化される' do
      expect(service.instance_variable_get(:@user)).to eq(user)
      expect(service.instance_variable_get(:@service)).to eq(mock_google_service)
    end
  end

  describe '#sync_calendar' do
    let(:google_event) do
      Google::Apis::CalendarV3::Event.new(
        id: 'google_event_1',
        summary: 'Synced Event',
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: 1.day.from_now),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: 1.day.from_now + 1.hour),
        description: 'Event Description'
      )
    end

    context 'サービスが利用可能な場合' do
      before do
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [google_event])
        )
      end

      it 'イベントを同期し成功を返す' do
        result = service.sync_calendar

        expect(result[:success]).to be true
        expect(result[:synced_count]).to eq(1)
        expect(result[:message]).to include('1件のイベントを同期しました')
      end

      it '新しいカレンダーイベントを作成する' do
        expect do
          service.sync_calendar
        end.to change { user.calendar_events.count }.by(1)

        calendar_event = user.calendar_events.first
        expect(calendar_event.google_event_id).to eq('google_event_1')
        expect(calendar_event.title).to eq('Synced Event')
        expect(calendar_event.google_calendar_id).to eq('primary')
      end

      it '既存のカレンダーイベントを更新する' do
        existing_event = create(:calendar_event, user:, google_event_id: 'google_event_1')
        original_title = existing_event.title

        google_event.summary = 'Updated Event'
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [google_event])
        )

        service.sync_calendar

        expect(existing_event.reload.title).to eq('Updated Event')
        expect(existing_event.title).not_to eq(original_title)
      end

      it 'タイトルなしのイベントを処理する' do
        google_event.summary = nil
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [google_event])
        )

        service.sync_calendar

        calendar_event = user.calendar_events.first
        expect(calendar_event.title).to eq('No Title')
      end

      it '終日イベントを処理する' do
        all_day_event = Google::Apis::CalendarV3::Event.new(
          id: 'all_day_event_1',
          summary: 'All Day Event',
          start: Google::Apis::CalendarV3::EventDateTime.new(date: Time.zone.today),
          end: Google::Apis::CalendarV3::EventDateTime.new(date: Time.zone.today + 1.day),
          description: 'All day event'
        )
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [all_day_event])
        )

        service.sync_calendar

        calendar_event = user.calendar_events.first
        expect(calendar_event.start_time.to_date).to eq(Time.zone.today)
        expect(calendar_event.end_time.to_date).to eq(Time.zone.today + 1.day)
      end

      it 'Google Calendarから削除されたイベントを削除する' do
        # Create existing event that will be deleted
        deleted_event = create(:calendar_event, user:, google_event_id: 'deleted_event_1')
        expect(user.calendar_events.count).to eq(1)

        # Sync with only the other event
        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [google_event])
        )

        service.sync_calendar

        # Deleted event should be removed
        expect(user.calendar_events.count).to eq(1)
        expect { deleted_event.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'ソフト削除されたイベントは削除しない' do
        create(:calendar_event, user:, google_event_id: 'soft_deleted_event', deleted_at: Time.current)

        allow(mock_google_service).to receive(:list_events).and_return(
          Google::Apis::CalendarV3::Events.new(items: [google_event])
        )

        service.sync_calendar

        # Soft-deleted event should still exist
        expect(CalendarEvent.unscoped.find_by(google_event_id: 'soft_deleted_event')).not_to be_nil
      end

      it 'イベントが再同期されたときにdeleted_atをクリアする' do
        calendar_event = create(:calendar_event, user:, google_event_id: 'google_event_1', deleted_at: 1.day.ago)
        expect(calendar_event.deleted_at).not_to be_nil

        service.sync_calendar

        expect(calendar_event.reload.deleted_at).to be_nil
      end

      it 'synced_atタイムスタンプを設定する' do
        service.sync_calendar

        calendar_event = user.calendar_events.first
        expect(calendar_event.synced_at).not_to be_nil
      end

      context '複数のイベントがある場合' do
        let(:second_event) do
          Google::Apis::CalendarV3::Event.new(
            id: 'google_event_2',
            summary: 'Second Event',
            start: Google::Apis::CalendarV3::EventDateTime.new(date_time: 2.days.from_now),
            end: Google::Apis::CalendarV3::EventDateTime.new(date_time: 2.days.from_now + 1.hour),
            description: 'Second event'
          )
        end

        it '複数のイベントを同期する' do
          allow(mock_google_service).to receive(:list_events).and_return(
            Google::Apis::CalendarV3::Events.new(items: [google_event, second_event])
          )

          result = service.sync_calendar

          expect(result[:synced_count]).to eq(2)
          expect(user.calendar_events.count).to eq(2)
        end
      end
    end

    context 'Google APIエラーが発生した場合' do
      it 'エラー結果を返しエラーをログに記録する' do
        error = Google::Apis::ClientError.new('Sync failed')
        allow(mock_google_service).to receive(:list_events).and_raise(error)
        allow(Rails.logger).to receive(:error).with("Calendar sync error: #{error.message}")

        result = service.sync_calendar

        expect(result[:success]).to be false
        expect(result[:error]).to include('Google Calendar との同期に失敗しました')
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'エラー結果を返す' do
        result = service.sync_calendar

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end

  describe '同期の時間範囲' do
    it '30日前から1年後までのイベントを取得する' do
      allow(mock_google_service).to receive(:list_events).and_return(
        Google::Apis::CalendarV3::Events.new(items: [])
      )

      service.sync_calendar

      expect(mock_google_service).to have_received(:list_events) do |_calendar_id, options|
        time_min = Time.zone.parse(options[:time_min])
        time_max = Time.zone.parse(options[:time_max])

        # Check approximate time ranges (allowing for rounding in RFC3339 format)
        expect(time_min).to be <= 30.days.ago
        expect(time_min).to be > 31.days.ago
        expect(time_max).to be > 1.year.from_now - 1.minute
        expect(time_max).to be < 1.year.from_now + 1.day
      end
    end
  end
end
