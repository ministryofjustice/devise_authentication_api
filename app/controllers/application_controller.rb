class ApplicationController < ActionController::API

  include ActionController::MimeResponds # details see: https://github.com/rails-api/rails-api/issues/24

  include ActionController::ImplicitRender
  include ActionController::StrongParameters

  respond_to :json

  skip_before_action :verify_authenticity_token # disable Cross-Site Request Forgery protection

  # # This is our new function that comes before Devise's one
  # before_filter :authenticate_user_from_token!
  # # This is Devise's authentication
  # before_filter :authenticate_user!
#
  # private
#
  # def authenticate_user_from_token!
    # user_email = params[:user_email].presence
    # user = user_email && User.find_by_email(user_email)
#
    # # Notice how we use Devise.secure_compare to compare the token
    # # in the database with the token given in the params, mitigating
    # # timing attacks.
    # if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      # sign_in user, store: false
    # end
  # end

  def render_success
    render text: '', status: :no_content
  end

  def render_errors errors
    render text: "{\"errors\":#{errors}}", status: :unprocessable_entity
  end

  def render_unauthorized
    render text: '{"error":"Invalid token."}', status: :unauthorized
  end

end
