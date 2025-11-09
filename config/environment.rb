# Load the Rails application.
require_relative 'application'

# Load environment variables from .env file
if File.exist?('.env')
  File.readlines('.env').each do |line|
    line.strip!
    next if line.empty? || line.start_with?('#')
    key, value = line.split('=', 2)
    ENV[key] = value if key && value
  end
end

# Initialize the Rails application.
Rails.application.initialize!

# OmniAuth middleware - must be configured AFTER Rails initialization
OmniAuth.config.logger = Rails.logger
OmniAuth.config.silence_get_warning = true
# OmniAuth 2.0: Allow GET requests (required for Devise integration)
OmniAuth.config.allowed_request_methods = [:get, :post]
