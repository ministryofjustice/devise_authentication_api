class UsersController < ApplicationController

  respond_to :json

  def update
    token = params[:authentication_token]
    if user = User.for_authentication_token(token)
      render text: '', status: :no_content
    else
      render text: '{"error":"Invalid token."}', status: :unauthorized
    end
  end

end
