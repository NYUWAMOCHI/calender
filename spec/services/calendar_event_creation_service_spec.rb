# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarEventCreationService, type: :service do
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

  describe '#create_event' do
    let(:title) { 'Test Event' }
    let(:start_time) { 1.day.from_now }
    let(:end_time) { 1.day.from_now + 1.hour }
    let(:description) { 'Test Description' }
    let(:created_event) do
      Google::Apis::CalendarV3::Event.new(
        id: 'event_123',
        summary: title,
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time)
      )
    end

    context 'サービスが利用可能な場合' do
      it 'Google Calendarにイベントを作成する' do
        allow(mock_google_service).to receive(:insert_event).and_return(created_event)

        result = service.create_event(title, start_time, end_time, 'primary', description)

        expect(result[:success]).to be true
        expect(result[:google_event_id]).to eq('event_123')
        expect(result[:event]).to eq(created_event)
      end

      it 'デフォルトの説明でイベントを作成する' do
        allow(mock_google_service).to receive(:insert_event) do |_calendar_id, event|
          expect(event.description).to eq('Created by TRPG Calendar')
          created_event
        end.and_return(created_event)

        service.create_event(title, start_time, end_time)
      end

      it 'デフォルトでプライマリカレンダーを使用する' do
        allow(mock_google_service).to receive(:insert_event).with(
          'primary',
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(created_event)

        result = service.create_event(title, start_time, end_time)
        expect(result[:success]).to be true
      end

      it 'カスタムcalendar_idを受け付ける' do
        custom_calendar_id = 'custom@example.com'
        allow(mock_google_service).to receive(:insert_event).with(
          custom_calendar_id,
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(created_event)

        result = service.create_event(title, start_time, end_time, custom_calendar_id)
        expect(result[:success]).to be true
      end

      it 'タイムゾーンをAsia/Tokyoに設定する' do
        allow(mock_google_service).to receive(:insert_event) do |_calendar_id, event|
          expect(event.start.time_zone).to eq('Asia/Tokyo')
          expect(event.end.time_zone).to eq('Asia/Tokyo')
          created_event
        end.and_return(created_event)

        service.create_event(title, start_time, end_time)
      end
    end

    context 'Google APIエラーが発生した場合' do
      it 'エラー結果を返しエラーをログに記録する' do
        error = Google::Apis::ClientError.new('API Error')
        allow(mock_google_service).to receive(:insert_event).and_raise(error)
        allow(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.create_event(title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'エラー結果を返す' do
        result = service.create_event(title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end

  describe '#update_event' do
    let(:google_event_id) { 'event_123' }
    let(:title) { 'Updated Event' }
    let(:start_time) { 2.days.from_now }
    let(:end_time) { 2.days.from_now + 1.hour }
    let(:description) { 'Updated Description' }
    let(:updated_event) do
      Google::Apis::CalendarV3::Event.new(
        id: google_event_id,
        summary: title,
        start: Google::Apis::CalendarV3::EventDateTime.new(date_time: start_time),
        end: Google::Apis::CalendarV3::EventDateTime.new(date_time: end_time)
      )
    end

    context 'サービスが利用可能な場合' do
      it 'Google Calendarのイベントを更新する' do
        allow(mock_google_service).to receive(:update_event).and_return(updated_event)

        result = service.update_event(google_event_id, title, start_time, end_time, 'primary', description)

        expect(result[:success]).to be true
        expect(result[:event]).to eq(updated_event)
      end

      it '指定されない場合はデフォルトの説明を使用する' do
        allow(mock_google_service).to receive(:update_event) do |_calendar_id, _event_id, event|
          expect(event.description).to eq('Updated by TRPG Calendar')
          updated_event
        end.and_return(updated_event)

        service.update_event(google_event_id, title, start_time, end_time)
      end

      it 'event_idを正しく渡す' do
        allow(mock_google_service).to receive(:update_event).with(
          'primary',
          google_event_id,
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(updated_event)

        result = service.update_event(google_event_id, title, start_time, end_time)
        expect(result[:success]).to be true
      end
    end

    context 'Google APIエラーが発生した場合' do
      it 'エラー結果を返しエラーをログに記録する' do
        error = Google::Apis::ClientError.new('Update failed')
        allow(mock_google_service).to receive(:update_event).and_raise(error)
        allow(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.update_event(google_event_id, title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'エラー結果を返す' do
        result = service.update_event(google_event_id, title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end

  describe '#delete_event' do
    let(:google_event_id) { 'event_123' }

    context 'サービスが利用可能な場合' do
      it 'Google Calendarからイベントを削除する' do
        allow(mock_google_service).to receive(:delete_event).with('primary', google_event_id)

        result = service.delete_event(google_event_id)

        expect(result[:success]).to be true
      end

      it 'カスタムcalendar_idを受け付ける' do
        custom_calendar_id = 'custom@example.com'
        allow(mock_google_service).to receive(:delete_event).with(
          custom_calendar_id,
          google_event_id
        )

        result = service.delete_event(google_event_id, custom_calendar_id)
        expect(result[:success]).to be true
      end
    end

    context 'Google APIエラーが発生した場合' do
      it 'エラー結果を返しエラーをログに記録する' do
        error = Google::Apis::ClientError.new('Delete failed')
        allow(mock_google_service).to receive(:delete_event).and_raise(error)
        allow(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.delete_event(google_event_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'サービスが利用できない場合' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'エラー結果を返す' do
        result = service.delete_event(google_event_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end
end
