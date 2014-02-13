require 'spec_helper'

describe '' do

  include ApiHelper
  include_context "shared setup"

  context 'unauthenticated user' do

    before { register_and_confirm @good_creds }

    describe 'reset password via PATCH /users/password' do
      before do
        ActionMailer::Base.deliveries.clear
        post '/users/password', {user: {email: @email}}

        message = ActionMailer::Base.deliveries.last
        @reset_token = message.body.raw_source[/reset_password_token=([^"]+)/,1]
      end

      describe 'success' do
        before do
          patch "/users/password/#{@reset_token}", {user: {password: 'newpassword'}}
        end

        it_behaves_like 'no content success response'

        it 'changes password' do
          user(@email).valid_password?('newpassword')
        end
      end

      describe 'failure due to missing password' do
        before do
          patch "/users/password/#{@reset_token}", {user: {email: @email}}
        end

        it 'returns 422 Unprocessible status code' do
          status_code_is 422
        end

        it 'returns error message' do
          json_contains 'errors', {"password"=>["cannot be blank"]}
        end

        it 'does not change password' do
          user(@email).valid_password?(@password)
        end
      end
    end
  end

end