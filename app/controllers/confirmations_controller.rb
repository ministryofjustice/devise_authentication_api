class ConfirmationsController < ApplicationController

  respond_to :json

  def create
    token = params[:confirmation_token]
    user = User.confirm_by_token(token)

    if user.try(:suspended?)
      render_forbidden user.inactive_message
    elsif user.try(:valid?)
      render_success
    else
      render_unauthorized
    end
  end

end
