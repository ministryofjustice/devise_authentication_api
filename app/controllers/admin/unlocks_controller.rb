module Admin; end

class Admin::UnlocksController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  def create
    email = params[:user] && params[:user][:email]

    if user = User.for_email(email)
      user.unlock_access!
      if user.valid?
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
