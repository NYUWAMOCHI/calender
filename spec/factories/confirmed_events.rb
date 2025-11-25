# frozen_string_literal: true

FactoryBot.define do
  factory :confirmed_event do
    group { create(:group) }
    scenario { create(:scenario, group: group) }
    start_time { 1.day.from_now }
    end_time { 1.day.from_now + 2.hours }
  end
end
