require 'spec_helper'

describe '' do

  include ApiHelper
  include_context "shared setup"

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_user = User.last
    @admin_token = @admin_user.authentication_token
    user = User.create! @good_creds[:user]
    user(@email).confirm!
    @user_params = {user: {email: @email}}
  end

  def call_api admin_token, params
    post "/admin/#{admin_token}/users/admin_user", params
  end

  describe 'POST /admin/:authentication_token/admin_users' do

    describe 'success adding admin rights' do
      before do
        call_api @admin_token, @user_params
      end

      it_behaves_like 'no content success response'

      it 'sets user is_admin_user status true' do
        user(@email).is_admin_user?.should be_true
      end
    end

    context 'invalid access' do
      let(:good_params) { @user_params }
      let(:bad_email_params) { {user: {email: 'bad_email'}} }

      it_behaves_like 'prevents invalid admin access'
    end
  end

  describe 'DELETE /admin/:authentication_token/admin_users' do

    describe 'success removing admin rights' do
      before do
        call_api @admin_token, @user_params
        delete "/admin/#{@admin_token}/users/admin_user", @user_params
      end

      it_behaves_like 'no content success response'

      it 'sets user is_admin_user status false' do
        user(@email).is_admin_user?.should be_false
      end
    end

  end
end