class SessionsController < ApplicationController

  respond_to :json

  def destroy
    token = params[:authentication_token]
    if user = User.for_authentication_token(token)
      user.authentication_token = nil
      user.save!
      render text: '', status: :no_content
    else
      render text: '{"error":"Invalid token."}', status: :unauthorized
    end
  end

end
