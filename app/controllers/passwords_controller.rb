class PasswordsController < ApplicationController

  respond_to :json

  def update
    token = params[:reset_password_token]
    password = params[:user] && params[:user][:password]

    if password.blank?
      errors = { 'password' => ["can't be blank"] }.to_json
      render text: "{\"errors\":#{errors}}", status: :unprocessable_entity
    else
      user = User.reset_password_by_token(reset_password_token: token, password: password, password_confirmation: password)

      if user.try(:suspended?)
        render_forbidden user.inactive_message
      elsif user.try(:valid?)
        render_success
      else
        render_unauthorized
      end
    end
  end

end
