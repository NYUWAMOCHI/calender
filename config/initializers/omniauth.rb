# frozen_string_literal: true

# OmniAuth configuration for Google OAuth 2.0
# This initializer configures Google OAuth2 authentication and Calendar API scopes

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    ENV.fetch('GOOGLE_CLIENT_ID', ''),
    ENV.fetch('GOOGLE_CLIENT_SECRET', ''),
    {
      scope: [
        'userinfo.email',
        'userinfo.profile',
        'https://www.googleapis.com/auth/calendar'
      ],
      access_type: 'offline',  # Important: Required to get refresh_token
      prompt: 'consent'         # Force consent screen on every login (useful for adding scopes)
    }
end

# Suppress OmniAuth warnings in test
OmniAuth.config.test_mode = true if Rails.env.test?
