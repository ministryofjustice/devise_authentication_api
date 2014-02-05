class ConfirmationsController < ApplicationController

  respond_to :json

  def create
    token = params[:confirmation_token]
    user = User.confirm_by_token(token)

    if user.errors.empty?
      render_success
    else
      render text: '{"error":"Invalid token."}', status: :unauthorized
    end
  end

end
