# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
DeviseAuthenticationApi::Application.initialize!

smtp_settings = {
  address:        ENV['SMTP_SERVER'] || 'smtp.sendgrid.net',
  port:           ENV['SMTP_PORT'] || '587',
  authentication: :plain,
  user_name:      ENV['SMTP_USERNAME'],
  password:       ENV['SMTP_PASSWORD'],
  enable_starttls_auto: true
}

smtp_settings.merge!(domain: ENV['SMTP_DOMAIN']) unless ENV['SMTP_DOMAIN'].blank?

ActionMailer::Base.smtp_settings = smtp_settings
