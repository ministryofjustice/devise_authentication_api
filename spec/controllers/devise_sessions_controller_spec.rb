require 'spec_helper'

describe 'sign in via POST /sessions' do

  include ApiHelper
  include_context "shared setup"

  context 'unauthenticated user' do

    before { register_and_confirm @good_creds }

    describe 'success' do
      before { sign_in @good_creds }

      it 'returns 201 status code' do
        status_code_is 201 # Created
      end

      it 'returns a secure token' do
        token = User.last.authentication_token
        token.should_not be_nil
        json_contains 'authentication_token', token
      end
    end

    shared_examples 'unauthorized with invalid credentials error' do
      it 'returns 401 Unauthorized status code' do
        status_code_is 401 # Unauthorized
      end

      it 'doesn\'t return a secure token' do
        json_should_not_contain 'authentication_token'
      end

      it 'returns "Invalid email or password." error' do
        json_contains 'error', 'Invalid email or password.'
      end

      it 'returns "Invalid email or password." error in JSON' do
        json_contains 'error', 'Invalid email or password.'
      end
    end

    describe 'after MAXIMUM_ATTEMPTS failed attempts' do
      before do
        attempts = ENV['MAXIMUM_ATTEMPTS'].to_i
        attempts.times do |i|
          sign_in @bad_password_creds
        end
      end

      it "has not locked user's access" do
        user(@email).access_locked?.should be_false
      end

      context 'sign in attempt with good password' do
        before { sign_in @good_creds }

        it 'returns 201 status code' do
          status_code_is 201 # Created
        end

        it 'returns a secure token' do
          token = User.last.authentication_token
          token.should_not be_nil
          json_contains 'authentication_token', token
        end
      end
    end

    describe 'after MAXIMUM_ATTEMPTS + 1 failed attempts' do
      before do
        ActionMailer::Base.deliveries.clear
        attempts = ENV['MAXIMUM_ATTEMPTS'].to_i
        attempts.times do |i|
          sign_in @bad_password_creds
        end
        sign_in @bad_password_creds
      end

      it "has locked user's access" do
        user(@email).access_locked?.should be_true
      end

      context 'sign in attempt with good password' do
        before { sign_in @good_creds }

        it 'returns 403 Forbidden status code' do
          status_code_is 403
        end

        it 'has account is locked error JSON' do
          json_contains 'error', 'Your account is locked.'
        end

        it 'sends email to user' do
          ActionMailer::Base.deliveries.count.should == 1
          message = ActionMailer::Base.deliveries.first

          message.to.should == [@email]
          message.from.should == [ENV['SENDER_EMAIL_ADDRESS']]
          message.subject.should == 'Unlock Instructions'
          message.body.raw_source.should include('http://testhost/users/unlock/')
        end
      end
    end

    describe 'failure due to invalid password' do
      before { sign_in @bad_password_creds }

      it_behaves_like 'unauthorized with invalid credentials error'
    end

    describe 'failure due to invalid email' do
      before { sign_in @bad_creds }

      it_behaves_like 'unauthorized with invalid credentials error'
    end
  end

end