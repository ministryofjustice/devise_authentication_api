require 'spec_helper'

describe '' do

  include ApiHelper
  include_context "shared setup"

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_user = User.last
    @admin_token = @admin_user.authentication_token
    user = User.create! @good_creds[:user]
  end

  describe 'get user via GET /admin/:authentication_token/users/?email=:email' do

    describe 'success' do
      before { get "/admin/#{@admin_token}/users?email=#{@email}" }

      it 'returns 200 OK status code' do
        status_code_is 200
      end

      it 'returns email in JSON' do
        json_contains 'email', @email
      end

      it 'returns suspended flag in JSON' do
        json_contains 'suspended', false
      end

      it 'does not return authentication_token in JSON' do
        json_should_not_contain 'authentication_token'
      end
    end

    describe 'failure due to suspended admin user' do
      before do
        @admin_user.suspended = true
        @admin_user.save

        get "/admin/#{@admin_token}/users?email=#{@email}"
      end

      it_behaves_like 'account suspended response'
    end

    describe 'failure due to invalid user email' do
      before { get "/admin/#{@admin_token}/users?email=wrong@example.com" }

      it 'returns 422 status code' do
        status_code_is 422
      end

      it 'returns error message' do
        json_contains 'error', 'No user found for email.'
      end
    end

    describe 'failure due to invalid token' do
      before { get "/admin/bad_token/users?email=#{@email}" }

      it_behaves_like 'unauthorized with invalid token error'
    end
  end

  describe 'set user suspended status via PATCH /admin/:authentication_token/users' do

    before do
      @user_suspended_params = {user: {email: @email, suspended: 'true'}}
      @user_reinstated_params = {user: {email: @email, suspended: 'false'}}
      @bad_user_suspended_params = {user: {email: 'bad@example.com', suspended: 'true'}}
      user(@email).confirm!
    end

    describe 'success setting suspended' do
      before { patch "/admin/#{@admin_token}/users", @user_suspended_params }

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

    describe 'and success re-instating' do
      before { patch "/admin/#{@admin_token}/users", @user_reinstated_params}

      it_behaves_like 'no content success response'

      it 'sets user suspended status false' do
        user(@email).suspended?.should be_false
      end
    end

    describe 'failure due to suspended admin user' do
      before do
        @admin_user.suspended = true
        @admin_user.save

        patch "/admin/#{@admin_token}/users", @user_suspended_params
      end

      it_behaves_like 'account suspended response'
    end

    describe 'failure due to invalid user email' do
      before { patch "/admin/#{@admin_token}/users", @bad_user_suspended_params }

      it 'returns 422 status code' do
        status_code_is 422
      end

      it 'returns error message' do
        json_contains 'error', 'No user found for email.'
      end
    end

    describe 'failure due to invalid token' do
      before { patch "/admin/bad_token/users", @user_suspended_params }

      it_behaves_like 'unauthorized with invalid token error'
    end
  end
end