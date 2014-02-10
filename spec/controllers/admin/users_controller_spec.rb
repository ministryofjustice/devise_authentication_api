require 'spec_helper'

describe 'get user via GET /admin/:authentication_token/users/:email' do

  include ApiHelper
  include_context "shared setup"

  context 'authenticated user' do
    before do
      INITIALIZE_ADMIN_USER.call
      @admin_token = User.last.authentication_token
      user = User.create! @good_creds[:user]
    end

    describe 'success' do
      before { get "/admin/#{@admin_token}/users?email=#{URI.encode(@email)}" }

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

    describe 'failure due to invalid user email' do
      before { get "/admin/#{@admin_token}/users?email=wrong@example.com" }

      it 'returns 422 status code' do
        status_code_is 422
      end

      it 'returns error message' do
        json_contains 'error', 'No user found for email.'
      end
    end

  end
end