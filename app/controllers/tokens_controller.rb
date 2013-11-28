class TokensController < ApplicationController

  respond_to :json

  def show
    token = params[:authentication_token]
    if (user = User.for_authentication_token(token)) && Devise.secure_compare(user.authentication_token, token)
      response.headers["X-USER-ID"]=user.email
      render text: ''
    else
      render text: '', status: :unauthorized
    end
  end

end
