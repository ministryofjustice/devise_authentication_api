require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

puts "==== RAILS_ENV: #{ENV['RAILS_ENV']}"

if ENV['SENDER_EMAIL_ADDRESS'].blank?
  raise 'you must set SENDER_EMAIL_ADDRESS environment variable'
end


INITIALIZE_ADMIN_USER = Proc.new do
  if ENV['INITIAL_ADMIN_USER_EMAIL'].blank?
    raise 'you must set INITIAL_ADMIN_USER_EMAIL environment variable'
  end

  unless User.where(email: ENV['INITIAL_ADMIN_USER_EMAIL']).exists?
    admin_user = User.new(email: ENV['INITIAL_ADMIN_USER_EMAIL'])
    admin_user.is_admin_user = true
    admin_user.skip_confirmation_notification! # stop email from being sent

    if Rails.env.test? || Rails.env.development?
      if ENV['TEST_INITIAL_ADMIN_PASSWORD'].blank?
        raise 'you must set TEST_INITIAL_ADMIN_PASSWORD environment variable for test and development environments'
      end
      admin_user.password = ENV['TEST_INITIAL_ADMIN_PASSWORD']
    end
    admin_user.save!
  end
end

module DeviseAuthenticationApi
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false

    # Disable the asset pipeline.
    config.assets.enabled = false

    config.action_mailer.default_url_options = { host: ENV["SITE_URL"] || "http://localhost:9393" }

    # HTTP default headers
    config.action_dispatch.default_headers = {
       'Cache-Control' => 'no-cache'
    }

    config.after_initialize do
      INITIALIZE_ADMIN_USER.call
    end
  end
end
