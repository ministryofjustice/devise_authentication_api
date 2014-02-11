module Admin; end

class Admin::RegistrationsController < Devise::RegistrationsController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended
  before_filter :return_unprocessible_if_password_provided

  protected

  include AuthenticateAdminUser

  def return_unprocessible_if_password_provided
    if params[:user] && params[:user][:password]
      errors = { 'password' => ['should not be provided'] }.to_json
      render text: "{\"errors\":#{errors}}", status: :unprocessable_entity
    end
  end

end
