require 'spec_helper'

describe 'registration via POST /users' do

  include ApiHelper
  include_context "shared setup"

  context 'unauthenticated user' do

    describe 'success' do
      before { register_and_confirm @good_creds }

      it 'returns 201 Created status code' do
        status_code_is 201 # Created
      end

      it 'returns "Cache-Control: no-cache" in header' do
        last_response['Cache-Control'].should == 'no-cache'
      end

      it 'returns "Content-Type: application/json; charset=utf-8" in header' do
        last_response['Content-Type'].should == 'application/json; charset=utf-8'
      end

      it 'returns Content-Length in header' do
        last_response['Content-Length'].should == '78'
      end

      it 'returns email in JSON' do
        json_contains 'email', @email
      end

      it 'does not return _id in JSON' do
        json_should_not_contain '_id'
      end

      it 'does not return authentication_token in JSON' do
        json_should_not_contain 'authentication_token'
      end

      it 'returns confirmation_token in JSON' do
        json_includes 'confirmation_token'
      end

      it 'sets user password' do
        User.last.valid_password?(@password).should be_true
      end
    end

    describe 'failure due to bad email and missing password' do
      before { register @bad_creds }

      it 'returns 422 Unprocessable Entity status code' do
        status_code_is 422 # Unprocessable Entity
      end

      it 'returns errors in JSON' do
        json_contains 'errors', {"email"=>["is invalid"]}
      end
    end

    describe 'failure due to too short password' do
      before { register @short_password_creds }

      it 'returns 422 Unprocessable Entity status code' do
        status_code_is 422 # Unprocessable Entity
      end

      it 'returns errors in JSON' do
        json_contains 'errors', {"password"=>["is too short (minimum is 8 characters)"]}
      end
    end
  end
end