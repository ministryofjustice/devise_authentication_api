require 'spec_helper'

describe 'registration of user via POST /admin/:token/users' do

  include ApiHelper
  include_context "shared setup"

  before do
    @user_params = {user: {email: @email} }
  end

  context 'by non-admin user' do
    before do
      user = User.create! @good_creds[:user]
      @token = user.authentication_token
    end

    describe 'failure' do
      before do
        post("/admin/#{@token}/users", @user_params)
      end

      it_behaves_like 'unauthorized with invalid token error'
    end
  end

  context 'by admin user' do
    before do
      INITIALIZE_ADMIN_USER.call
      @admin_token = User.last.authentication_token
    end

    describe 'success' do
      before do
        ActionMailer::Base.deliveries.clear
        post("/admin/#{@admin_token}/users", @user_params)
      end

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

      it 'sends confirmation email to new user' do
        ActionMailer::Base.deliveries.count.should == 1
        message = ActionMailer::Base.deliveries.first
        message.to.should == [@email]
        message.from.should == [ENV['SENDER_EMAIL_ADDRESS']]
        message.subject.should == 'Confirmation instructions'
      end

      it 'sets user password blank' do
        user(@email).encrypted_password.should be_blank
      end

      it 'sets is_admin_user to false' do
        user(@email).is_admin_user.should be_false
      end
    end

    describe 'failure due to bad email' do
      before do
        post("/admin/#{@admin_token}/users", {user: {email: 'bademail'} } )
      end

      it 'returns 422 Unprocessable Entity status code' do
        status_code_is 422 # Unprocessable Entity
      end

      it 'returns errors in JSON' do
        json_contains 'errors', {"email"=>["is invalid"]}
      end
    end

  end
end