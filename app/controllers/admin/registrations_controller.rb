module Admin; end

class Admin::RegistrationsController < Devise::RegistrationsController

  respond_to :json

end
