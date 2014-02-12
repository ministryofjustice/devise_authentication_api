module Admin; end

class Admin::AdminUsersController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  def create
    email = params[:user] && params[:user][:email]

    if user = User.for_email(email)
      user.is_admin_user = true

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

  def destroy
    email = params[:user] && params[:user][:email]

    if user = User.for_email(email)
      user.is_admin_user = false

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
