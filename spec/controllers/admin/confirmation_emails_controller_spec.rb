require 'spec_helper'

describe 'resend confirmation email via POST /admin/:token/users' do

  include ApiHelper
  include_context "shared setup"

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_user = User.last
    @admin_token = @admin_user.authentication_token
    @user = User.create! @good_creds[:user]
  end

  def call_api admin_token, params
    ActionMailer::Base.deliveries.clear
    post "/admin/#{admin_token}/users/confirm", params
  end

  describe 'success sending email' do
    before do
      call_api @admin_token, {user: {email: @email}}
    end

    it_behaves_like 'no content success response'

    include_examples 'sends confirmation email'
  end

  context 'invalid access' do
    let(:good_params) { @user_params }
    let(:bad_email_params) { {user: {email: 'bad@example.com'}} }

    it_behaves_like 'prevents invalid admin access'
  end

end