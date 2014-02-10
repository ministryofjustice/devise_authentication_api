require 'spec_helper'

describe 'unlock account via POST /users/unlock/:unlock_token' do

  include ApiHelper
  include_context "shared setup"

  context 'locked account' do
    before do
      ActionMailer::Base.deliveries.clear
      register_and_confirm @good_creds
      attempts = ENV['MAXIMUM_ATTEMPTS'].to_i
      attempts.times do |i|
        sign_in @bad_password_creds
      end
      sign_in @bad_password_creds
      message = ActionMailer::Base.deliveries.first
      @token = message.body.raw_source[/unlock\/([^"]+)/,1]
    end

    describe 'success' do
      before do
        post "/users/unlock/#{@token}"
      end

      it_behaves_like 'no content success response'

      it 'unlocks user' do
        user(@email).access_locked?.should be_false
      end
    end

    context 'suspended user' do
      describe 'failure' do
        before do
          user = user(@email)
          user.suspended = true
          user.save
          post "/users/unlock/#{@token}"
        end

        it_behaves_like 'account suspended response'
      end
    end

    describe 'failure due to second call with same token' do
      before do
        post "/users/unlock/#{@token}"
        post "/users/unlock/#{@token}"
      end

      it_behaves_like 'unauthorized with invalid token error'

      it 'keeps user unlocked' do
        user(@email).access_locked?.should be_false
      end
    end

    describe 'failure due to invalid unlock_token' do
      before do
        post "/users/unlock/bad_token"
      end

      it_behaves_like 'unauthorized with invalid token error'

      it 'does not unlock user' do
        user(@email).access_locked?.should be_true
      end
    end
  end
end