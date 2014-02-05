module Admin; end

class Admin::RegistrationsController < Devise::RegistrationsController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user

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
