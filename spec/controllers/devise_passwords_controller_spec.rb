require 'spec_helper'

describe '' do

  include ApiHelper
  include_context "shared setup"

  context 'unauthenticated user' do

    before { register_and_confirm @good_creds }

    describe 'request password reset for confirmed user via POST /users/password' do
      before do
        ActionMailer::Base.deliveries.clear
        post '/users/password', {user: {email: @email}}
      end

      it 'returns 201 Created status code' do
        status_code_is 201
      end

      it 'returns empty JSON' do
        last_response.body.should == '{}'
      end

      it 'sends email to user' do
        ActionMailer::Base.deliveries.count.should == 1
        message = ActionMailer::Base.deliveries.first

        message.to.should == [@email]
        message.from.should == [ENV['SENDER_EMAIL_ADDRESS']]
        message.subject.should == 'Reset password instructions'
        message.body.raw_source.should include('http://testhost/users/password/')
      end
    end
  end

  context 'unauthenticated user' do

    before { register @good_creds }

    describe 'request password reset for unconfirmed user via POST /users/password' do
      before do
        ActionMailer::Base.deliveries.clear
        post '/users/password', {user: {email: @email}}
      end

      it 'be sure that user is unconfirmed' do
        user(@email).confirmed?.should be_false
      end

      it 'returns 201 Created status code' do
        status_code_is 201
      end

      it 'returns empty JSON' do
        last_response.body.should == '{}'
      end

      it 'sends email to user' do
        ActionMailer::Base.deliveries.count.should == 1
        message = ActionMailer::Base.deliveries.first

        message.to.should == [@email]
        message.from.should == [ENV['SENDER_EMAIL_ADDRESS']]
        message.subject.should == 'Reset password instructions'
        message.body.raw_source.should include('http://testhost/users/password/')
      end
    end
  end
end