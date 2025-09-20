# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'userinfo.email,userinfo.profile,https://www.googleapis.com/auth/calendar',
    access_type: 'offline',
    prompt: 'consent'
  }
end

OmniAuth.config.allowed_request_origin = Rails.application.config.allowed_request_origin if Rails.application.config.respond_to?(:allowed_request_origin)
OmniAuth.config.silence_get_warnings = true
