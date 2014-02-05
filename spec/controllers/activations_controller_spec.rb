require 'spec_helper'

describe 'activation via POST /users/activation/:confirmation_token' do

  include ApiHelper
  include_context 'shared setup'

  before do
    INITIALIZE_ADMIN_USER.call
    @admin_token = User.last.authentication_token
    user_params = {user: {email: @email} }
    post("/admin/#{@admin_token}/users", user_params)
    @confirmation_token = JSON.parse(last_response.body)['confirmation_token_for_tests_only']
    @password_params = {user: {password: @password} }
  end

  context 'by unactivated user' do

    describe 'success' do
      before do
        post("/users/activation/#{@confirmation_token}", @password_params)
      end

      it_behaves_like 'no content success response'

      it 'sets user password' do
        user(@email).valid_password?(@password).should be_true
      end

      it 'has confirmed user' do
        user(@email).confirmed?.should be_true
      end
    end
  end

  context 'by already activated user' do
    describe 'failure' do
      before do
        post("/users/activation/#{@confirmation_token}", @password_params)
        post("/users/activation/#{@confirmation_token}", @password_params)
      end

      it 'returns 401 Unauthorised status code' do
        status_code_is 401
      end

      it 'returns "Invalid token." error' do
        json_contains 'error', 'Invalid token.'
      end
    end
  end

  context 'with bad confirmation_token' do
    describe 'failure' do
      before do
        post("/users/activation/bad_token", @password_params)
      end

      it 'returns 401 Unauthorised status code' do
        status_code_is 401
      end

      it 'returns "Invalid token." error' do
        json_contains 'error', 'Invalid token.'
      end

      it 'has not set user password' do
        user(@email).valid_password?(@password).should be_false
      end

      it 'has not confirmed user' do
        user(@email).confirmed?.should be_false
      end
    end
  end
end