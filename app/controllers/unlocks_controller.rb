class UnlocksController < ApplicationController

  respond_to :json

  def create
    token = params[:unlock_token]
    user = User.unlock_access_by_token(token)

    if user.try(:suspended?)
      render_unauthorized user.inactive_message
    elsif user.try(:valid?)
      render_success
    else
      render_unauthorized
    end
  end

end
