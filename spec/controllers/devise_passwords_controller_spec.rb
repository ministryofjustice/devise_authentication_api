require 'spec_helper'

describe 'request password reset via POST /users/password' do

  include ApiHelper
  include_context "shared setup"

  context 'unauthenticated user' do

    before { register_and_confirm @good_creds }

    describe 'success' do
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
        message.body.raw_source.should include('http://testhost/users/password/edit?reset_password_token=')
      end
    end
  end


end