module Admin; end

class Admin::SuspendsController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  def create
    email = params[:user] && params[:user][:email]

    if user = User.for_email(email)
      user.suspended = true

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
      user.suspended = false

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
