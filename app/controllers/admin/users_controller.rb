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

  protected

  include AuthenticateAdminUser
end
