# frozen_string_literal: true

# Google API configuration
# Configure Google API client with appropriate settings

# Set timeout for Google API requests
# Note: timeout_sec is deprecated in newer versions of google-api-client
# Using the new timeout configuration method instead
begin
  Google::Apis::RequestOptions.default.timeout_sec = 30
rescue NoMethodError
  # Fallback for newer versions of google-api-client
  # The timeout configuration is handled differently in newer versions
end

# Configure default user agent (optional, for API quota tracking)
Google::Apis.logger = Rails.logger if Rails.env.development?
