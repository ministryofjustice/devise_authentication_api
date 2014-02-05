class UsersController < ApplicationController

  respond_to :json

  def update
    new_password = params[:user] && params[:user][:password]
    token = params[:authentication_token]

    if !new_password
      render_errors({"password"=>["can't be blank"]}.to_json)
    elsif (user = User.for_authentication_token(token))
      setter = PasswordSetter.new(user)
      setter.set_password new_password, self
    else
      render_unauthorized
    end
  end
end
