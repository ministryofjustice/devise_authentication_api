# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

require ::File.expand_path('../lib/rack/json_content_length',  __FILE__)
use Rack::JsonContentLength

run Rails.application
