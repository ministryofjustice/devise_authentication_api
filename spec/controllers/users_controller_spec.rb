require 'spec_helper'

describe 'change password via PATCH /users/:authentication_token' do

  include ApiHelper
  include_context "shared setup"

  context 'authenticated user' do
    before do
      user = User.create! @good_creds[:user]
      @token = user.authentication_token
    end

    describe 'success' do
      before { patch "/users/#{@token}", @new_password_params }

      it_behaves_like 'no content success response'

      it 'changes user password' do
        User.last.valid_password?(@new_password)
      end
    end

    describe 'failure due to missing password' do
      before { patch "/users/#{@token}", {} }

      it 'returns 422 Unprocessable Entity status code' do
        status_code_is 422 # Unprocessable Entity
      end

      it 'returns "Invalid password." error' do
        json_contains 'errors',  {"password"=>["can't be blank"]}
      end
    end

    describe 'failure due to short password' do
      before { patch "/users/#{@token}", @too_short_password_params }

      it 'returns 422 Unprocessable Entity status code' do
        status_code_is 422 # Unprocessable Entity
      end

      it 'returns "Invalid token." error' do
        json_contains 'errors',  {"password"=>["is too short (minimum is 8 characters)"]}
      end

      it 'does not change user password' do
        User.last.valid_password?(@new_password).should be_false
        User.last.valid_password?(@password).should be_true
      end
    end

    describe 'failure due to invalid token' do
      before { patch '/users/bad_token', @new_password_params }

      it_behaves_like 'unauthorized with invalid token error'

      it 'does not change user password' do
        User.last.valid_password?(@new_password).should be_false
        User.last.valid_password?(@password).should be_true
      end
    end

  end
end