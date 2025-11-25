# frozen_string_literal: true

FactoryBot.define do
  factory :approval do
    pending_event { create(:pending_event) }
    user { create(:user) }
    approved { false }
    auto_created { false }
  end
end
