module Admin; end

class Admin::ConfirmationEmailsController < ApplicationController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  def create
    email = params[:user] && params[:user][:email]

    if user = User.for_email(email)
      if user.confirmed?
        render_error 'User is already confirmed.'
      else
        user.send_confirmation_instructions
        render_success
      end
    else
      render_error 'No user found for email.'
    end
  end

  protected

  include AuthenticateAdminUser
end
