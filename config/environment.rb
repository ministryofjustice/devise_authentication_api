# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
DeviseAuthenticationApi::Application.initialize!

smtp_settings = { 
  address:        "localhost" || 'smtp.sendgrid.net',
  port:           "25" || '587'
}

smtp_settings.merge!(domain: ENV['SMTP_DOMAIN']) unless ENV['SMTP_DOMAIN'].blank?

ActionMailer::Base.smtp_settings = smtp_settings
