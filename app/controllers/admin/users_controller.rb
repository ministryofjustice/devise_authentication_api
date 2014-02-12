module Admin; end

class Admin::UsersController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  def show
    if user = User.for_email(params[:email])
      render json: user.as_json(admin: true)
    else
      render_error 'No user found for email.'
    end
  end

  def update
    email = params[:user] && params[:user][:email]
    suspended = params[:user] && params[:user][:suspended]
    is_admin_user = params[:user] && params[:user][:is_admin_user]

    if user = User.for_email(email)
      user.suspended = suspended
      user.is_admin_user = is_admin_user

      if user.valid?
        user.save!
        render_success
      else
        errors = user.errors.messages.to_json
        render_errors errors
      end
    else
      render_error 'No user found for email.'
    end
  end

  protected

  include AuthenticateAdminUser

end
