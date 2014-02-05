class SessionsController < ApplicationController

  respond_to :json

  def destroy
    token = params[:authentication_token]
    if user = User.for_authentication_token(token)
      user.authentication_token = nil
      user.save!
      render_success
    else
      render_unauthorized
    end
  end

end
