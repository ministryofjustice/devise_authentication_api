class SessionsController < ApplicationController

  respond_to :json

  def destroy
    token = params[:authentication_token]
    if user = User.for_authentication_token(token)
      if user.suspended?
        render_forbidden user.inactive_message
      else
        user.authentication_token = nil
        user.save!
        render_success
      end
    else
      render_unauthorized
    end
  end

end
