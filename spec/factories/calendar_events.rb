# frozen_string_literal: true

FactoryBot.define do
  factory :calendar_event do
    association :user
    sequence(:google_event_id) { |n| "event_#{n}" }
    sequence(:title) { |n| "Event #{n}" }
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 1.hour }
    description { 'Test event description' }
    google_calendar_id { 'primary' }
    synced_at { Time.current }
  end
end
