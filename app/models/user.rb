class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Associations
  has_many :groups, dependent: :destroy # KP として作成したグループ
  has_many :memberships, dependent: :destroy
  has_many :group_members, through: :memberships, source: :group
  has_many :pending_events, through: :groups
  has_many :confirmed_events, through: :groups
  has_many :approvals, dependent: :destroy
  has_many :calendar_events, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :user_scenarios, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 20 }
  validates :email, presence: true, uniqueness: true
  validates :google_uid, uniqueness: true, allow_nil: true

  def self.from_omniauth(auth)
    where(google_uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.google_uid = auth.uid
      user.google_access_token = auth.credentials.token
      user.google_refresh_token = auth.credentials.refresh_token
      user.google_token_expires_at = Time.zone.at(auth.credentials.expires_at) if auth.credentials.expires_at
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def google_token_expired?
    google_token_expires_at && google_token_expires_at < Time.current
  end

  # Build Google Calendar service for API access
  def google_calendar_service
    return nil unless google_access_token.present?

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = build_google_authorization
    service
  end

  private

  # Build OAuth2 authorization object for Google API calls
  def build_google_authorization
    Signet::OAuth2::Client.new(
      client_id: ENV.fetch('GOOGLE_CLIENT_ID', ''),
      client_secret: ENV.fetch('GOOGLE_CLIENT_SECRET', ''),
      access_token: google_access_token,
      refresh_token: google_refresh_token
    )
  end
end
