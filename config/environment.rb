# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
DeviseAuthenticationApi::Application.initialize!

smtp_settings = {
  address:        "smtp.sendgrid.net" || 'smtp.sendgrid.net',
  port:           "587" || '587',
  authentication: :plain,
  user_name:      "opg-backoffice",
  password:       "UYTFGKJBJgvjhkjYTFGKHKHjhbkhjvyRKJJHV",
  enable_starttls_auto: true
}

smtp_settings.merge!(domain: ENV['SMTP_DOMAIN']) unless ENV['SMTP_DOMAIN'].blank?

ActionMailer::Base.smtp_settings = smtp_settings
