# frozen_string_literal: true

# Google API configuration
# Configure Google API client with appropriate settings

# Set timeout for Google API requests
Google::Apis::RequestOptions.default.timeout_sec = 30

# Configure default user agent (optional, for API quota tracking)
Google::Apis.logger = Rails.logger if Rails.env.development?
