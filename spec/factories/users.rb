# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
