require 'spec_helper'

describe '' do

  include ApiHelper
  include_context "shared setup"

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_user = User.last
    @admin_token = @admin_user.authentication_token
    user = User.create! @good_creds[:user]
    user.confirm!
    @user_params = {user: {email: @email}}
  end

  def call_api admin_token, params
    post "/admin/#{admin_token}/users/suspend", params
  end

  describe 'suspend user via POST admin/:authentication_token/users/suspend' do

    describe 'success setting suspended status' do
      before do
        call_api @admin_token, @user_params
      end

      it_behaves_like 'no content success response'

      it 'sets user suspended status true' do
        user(@email).suspended?.should be_true
      end

      describe 'and subsequent sign in fails' do
        before do
          sign_in @good_creds
        end

        it_behaves_like 'account suspended response'
      end
    end

    context 'invalid access' do
      let(:good_params) { @user_params }
      let(:bad_email_params) { {user: {email: 'bad@example.com'}} }

      it_behaves_like 'prevents invalid admin access'
    end
  end

  describe 'reinstate user via DELETE admin/:authentication_token/users/suspend' do
    describe 'success re-instating a suspended user' do
      before do
        call_api @admin_token, @user_params
        delete "/admin/#{@admin_token}/users/suspend", @user_params
      end

      it_behaves_like 'no content success response'

      it 'sets user suspended status false' do
        user(@email).suspended?.should be_false
      end
    end
  end
end