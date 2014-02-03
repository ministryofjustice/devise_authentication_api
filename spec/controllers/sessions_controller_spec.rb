require 'spec_helper'

describe 'sign out via DELETE /sessions/[token]' do

  include ApiHelper
  include_context "shared setup"

  context 'authenticated user' do
    before do
      user = User.create! @good_creds[:user]
      @token = user.authentication_token
    end

    before { sign_in @good_creds }

    describe 'success' do
      before { delete "/sessions/#{@token}" }

      it 'resets user authentication_token' do
        User.last.authentication_token.should_not eq @token
      end

      it_behaves_like 'no content success response'
    end

    describe 'failure due to invalid token' do
      before { delete "/sessions/bad_token" }

      it_behaves_like 'unauthorized with invalid token error'
    end
  end

end