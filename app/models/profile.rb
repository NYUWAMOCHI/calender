class Profile < ApplicationRecord
  belongs_to :group
  belongs_to :user

  validates :title, presence: true, length: { maximum: 20 }
  validates :description, length: { maximum: 3000 }, allow_blank: true
end
