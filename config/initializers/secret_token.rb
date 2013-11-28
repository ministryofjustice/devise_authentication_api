# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.

unless Rails.env.production?
  ENV['SECRET_KEY_BASE'] = 'fd63a4c926f127cff27801980f7857db3159fbb3f1b030408a2cd91dbde0f8153efe61fcbc97ff247138ea2b0ab7fe5d40e6fd061350bb62c125728c271e81b2'
end

# Although this is not needed for an api-only application, rails4
# requires secret_key_base or secret_toke to be defined, otherwise an
# error is raised.
DeviseAuthenticationApi::Application.config.secret_key_base = ENV['SECRET_KEY_BASE']
