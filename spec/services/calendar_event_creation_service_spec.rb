# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarEventCreationService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:mock_google_service) { instance_double('Google::Apis::CalendarV3::CalendarService') }
  let(:fixed_time) { Time.zone.parse('2025-11-21 10:00:00') }

  before do
    allow(user).to receive(:google_calendar_service).and_return(mock_google_service)
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

    context 'when service is available' do
      it 'creates an event in Google Calendar' do
        expect(mock_google_service).to receive(:insert_event).and_return(created_event)

        result = service.create_event(title, start_time, end_time, 'primary', description)

        expect(result[:success]).to be true
        expect(result[:google_event_id]).to eq('event_123')
        expect(result[:event]).to eq(created_event)
      end

      it 'creates an event with default description' do
        expect(mock_google_service).to receive(:insert_event) do |_calendar_id, event|
          expect(event.description).to eq('Created by TRPG Calendar')
          created_event
        end.and_return(created_event)

        service.create_event(title, start_time, end_time)
      end

      it 'uses primary calendar by default' do
        expect(mock_google_service).to receive(:insert_event).with(
          'primary',
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(created_event)

        service.create_event(title, start_time, end_time)
      end

      it 'accepts custom calendar_id' do
        custom_calendar_id = 'custom@example.com'
        expect(mock_google_service).to receive(:insert_event).with(
          custom_calendar_id,
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(created_event)

        service.create_event(title, start_time, end_time, custom_calendar_id)
      end

      it 'sets timezone to Asia/Tokyo' do
        expect(mock_google_service).to receive(:insert_event) do |_calendar_id, event|
          expect(event.start.time_zone).to eq('Asia/Tokyo')
          expect(event.end.time_zone).to eq('Asia/Tokyo')
          created_event
        end.and_return(created_event)

        service.create_event(title, start_time, end_time)
      end
    end

    context 'when Google API error occurs' do
      it 'returns error result and logs error' do
        error = Google::Apis::ClientError.new('API Error')
        expect(mock_google_service).to receive(:insert_event).and_raise(error)
        expect(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.create_event(title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'when service is not available' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'returns error result' do
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

    context 'when service is available' do
      it 'updates an event in Google Calendar' do
        expect(mock_google_service).to receive(:update_event).and_return(updated_event)

        result = service.update_event(google_event_id, title, start_time, end_time, 'primary', description)

        expect(result[:success]).to be true
        expect(result[:event]).to eq(updated_event)
      end

      it 'uses default description when not provided' do
        expect(mock_google_service).to receive(:update_event) do |_calendar_id, _event_id, event|
          expect(event.description).to eq('Updated by TRPG Calendar')
          updated_event
        end.and_return(updated_event)

        service.update_event(google_event_id, title, start_time, end_time)
      end

      it 'passes event_id correctly' do
        expect(mock_google_service).to receive(:update_event).with(
          'primary',
          google_event_id,
          kind_of(Google::Apis::CalendarV3::Event)
        ).and_return(updated_event)

        service.update_event(google_event_id, title, start_time, end_time)
      end
    end

    context 'when Google API error occurs' do
      it 'returns error result and logs error' do
        error = Google::Apis::ClientError.new('Update failed')
        expect(mock_google_service).to receive(:update_event).and_raise(error)
        expect(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.update_event(google_event_id, title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'when service is not available' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'returns error result' do
        result = service.update_event(google_event_id, title, start_time, end_time)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end

  describe '#delete_event' do
    let(:google_event_id) { 'event_123' }

    context 'when service is available' do
      it 'deletes an event from Google Calendar' do
        expect(mock_google_service).to receive(:delete_event).with('primary', google_event_id)

        result = service.delete_event(google_event_id)

        expect(result[:success]).to be true
      end

      it 'accepts custom calendar_id' do
        custom_calendar_id = 'custom@example.com'
        expect(mock_google_service).to receive(:delete_event).with(
          custom_calendar_id,
          google_event_id
        )

        service.delete_event(google_event_id, custom_calendar_id)
      end
    end

    context 'when Google API error occurs' do
      it 'returns error result and logs error' do
        error = Google::Apis::ClientError.new('Delete failed')
        expect(mock_google_service).to receive(:delete_event).and_raise(error)
        expect(Rails.logger).to receive(:error).with("Google Calendar API Error: #{error.message}")

        result = service.delete_event(google_event_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq(error.message)
      end
    end

    context 'when service is not available' do
      before do
        allow(user).to receive(:google_calendar_service).and_return(nil)
      end

      it 'returns error result' do
        result = service.delete_event(google_event_id)

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Google Calendar に接続していません')
      end
    end
  end
end
