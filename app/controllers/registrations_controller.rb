class RegistrationsController < Devise::RegistrationsController

  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.skip_confirmation_notification! # stop email from being sent

    if resource.save
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
      else
        expire_data_after_sign_in!
      end
    else
      clean_up_passwords resource
    end

    respond_with resource, :location => nil
  end

end
