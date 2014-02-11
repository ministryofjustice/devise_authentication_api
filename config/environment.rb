# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
DeviseAuthenticationApi::Application.initialize!

smtp_settings = {
  address:        'smtp.sendgrid.net',
  port:           '587',
  authentication: :plain,
  user_name:      ENV['SENDGRID_USERNAME'],
  password:       ENV['SENDGRID_PASSWORD'],
  enable_starttls_auto: true
}

smtp_settings.merge!(domain: ENV['SENDGRID_DOMAIN']) unless ENV['SENDGRID_DOMAIN'].blank?

ActionMailer::Base.smtp_settings = smtp_settings
