# frozen_string_literal: true

FactoryBot.define do
  factory :scenario do
    group { create(:group) }
    sequence(:name) { |n| "Scenario#{n}" }
  end
end
