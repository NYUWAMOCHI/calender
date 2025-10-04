class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Associations
  has_many :groups, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :calendars, dependent: :destroy
  has_many :scenarios, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :user_scenarios, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    where(google_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.google_uid = auth.uid
      user.google_access_token = auth.credentials.token
      user.google_refresh_token = auth.credentials.refresh_token
      user.google_token_expires_at = Time.at(auth.credentials.expires_at) if auth.credentials.expires_at
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def google_token_expired?
    google_token_expires_at && google_token_expires_at < Time.current
  end
end
