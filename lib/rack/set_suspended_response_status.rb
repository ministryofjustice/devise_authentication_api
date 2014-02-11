require 'rack/utils'

module Rack

  # Sets the HTTP response status code to 403 on suspended account responses.
  class SetSuspendedResponseStatus
    include Rack::Utils

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers = HeaderHash.new(headers)

      if status == 401 && body.body && body.body[/Your account is suspended|Your account is locked/]
        status = 403
        body.status = 403
      end

      [status, headers, body]
    end
  end
end
