class ConfirmationsController < ApplicationController

  respond_to :json

  def create
    token = params[:confirmation_token]
    user = User.confirm_by_token(params[:confirmation_token])

    if user.errors.empty?
      render text: '', status: :no_content
    else
      render text: '{"error":"Invalid token."}', status: :unprocessable_entity
    end
  end

end
