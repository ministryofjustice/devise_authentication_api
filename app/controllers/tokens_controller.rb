class TokensController < ApplicationController

  respond_to :json

  def show
    token = params[:authentication_token]
    if (user = User.for_authentication_token(token)) && Devise.secure_compare(user.authentication_token, token)
      respond_with user
    else
      render text: '{"error":"Invalid token."}', status: :unauthorized
    end
  end

end
