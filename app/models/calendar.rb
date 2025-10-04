class Calendar < ApplicationRecord
  belongs_to :user

  validates :google_calendar_id, uniqueness: true, allow_blank: true
  validates :name, presence: true
end
