class UsersController < ApplicationController

  respond_to :json

  def update
    new_password = params[:user][:password]
    token = params[:authentication_token]
    if new_password && (user = User.for_authentication_token(token))
      user.password = new_password
      if user.valid?
        user.save!
        render text: '', status: :no_content
      else
        errors = user.errors.messages.to_json
        render text: "{\"errors\":#{errors}}", status: :unprocessable_entity
      end
    else
      render text: '{"error":"Invalid token."}', status: :unauthorized
    end
  end

end
