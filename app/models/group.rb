class Group < ApplicationRecord
  belongs_to :user
  has_many :memberships, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :profiles, dependent: :destroy

  validates :name, presence: true
end
