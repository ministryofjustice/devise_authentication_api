module Admin; end

class Admin::UsersController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user

  def show
    email = params[:email]
    if user = User.for_email(email)
      render json: user.as_json(admin: true)
    else
      render_error 'No user found for email.'
    end
  end

  protected

  def return_unauthorised_if_not_admin_user
    token = params[:authentication_token]
    if (user = User.for_authentication_token(token)) && user.is_admin_user
      # ok
    else
      render_unauthorized
    end

  end

end
