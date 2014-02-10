class ActivationsController < ApplicationController

  respond_to :json

  def create
    new_password = params[:user] && params[:user][:password]
    token = params[:confirmation_token]

    if !new_password
      render_errors({"password"=>["can't be blank"]}.to_json)

    elsif (@user = User.for_confirmation_token(token))

      if @user.try(:suspended?)
        render_unauthorized @user.inactive_message
      else
        setter = PasswordSetter.new(@user)
        setter.set_password new_password, self
      end
    else
      render_unauthorized
    end
  end

  def render_success
    @user.confirm!
    super
  end

end
