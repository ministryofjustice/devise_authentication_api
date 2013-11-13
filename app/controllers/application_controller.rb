class ApplicationController < ActionController::API

  include ActionController::MimeResponds # details see: https://github.com/rails-api/rails-api/issues/24

  include ActionController::ImplicitRender
  include ActionController::StrongParameters

  respond_to :json

  skip_before_action :verify_authenticity_token # disable Cross-Site Request Forgery protection

end
