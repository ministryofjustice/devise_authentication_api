module Admin; end

class Admin::RegistrationsController < Devise::RegistrationsController

  respond_to :json

  before_filter :return_unauthorised_if_not_admin_user_or_suspended

  protected

  include AuthenticateAdminUser

end
