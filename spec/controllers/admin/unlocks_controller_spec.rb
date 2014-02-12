require 'spec_helper'

describe 'unlock via POST /admin/:authentication_token/users/unlock' do

  include ApiHelper
  include_context "shared setup"

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_user = User.last
    @admin_token = @admin_user.authentication_token
    @user = User.create! @good_creds[:user]
  end

  context 'locked user' do
    before do
      @user.lock_access!
    end

    it 'is locked' do
      user(@email).access_locked?.should be_true
    end

    def call_api admin_token, params
      post "/admin/#{admin_token}/users/unlock", params
    end

    describe 'success' do
      before do
        @user_params = {user: {email: @email}}
        call_api @admin_token, @user_params
      end

      it_behaves_like 'no content success response'

      it 'unlocked user account' do
        user(@email).access_locked?.should be_false
      end
    end

    context 'invalid access' do
      let(:good_params) { @user_params }
      let(:bad_email_params) { {user: {email: 'bad_email'}} }

      it_behaves_like 'prevents invalid admin access'
    end

  end

end