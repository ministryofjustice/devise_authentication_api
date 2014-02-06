class UnlocksController < Devise::RegistrationsController

  respond_to :json

  def create
    token = params[:unlock_token]
    if (user = User.unlock_access_by_token(token)) && user.valid?
      render_success
    else
      render_unauthorized
    end
  end

end
