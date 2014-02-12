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

    describe 'success' do
      before do
        @user_params = {user: {email: @email}}
        post "/admin/#{@admin_token}/users/unlock", @user_params
      end

      it_behaves_like 'no content success response'

      it 'unlocked user account' do
        user(@email).access_locked?.should be_false
      end
    end
  end

end