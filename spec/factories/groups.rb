# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    user
    sequence(:name) { |n| "Group#{n}" }
    intro { 'Test group introduction' }
    planned_period_start { 1.month.from_now }
    planned_period_end { 3.months.from_now }
  end
end
