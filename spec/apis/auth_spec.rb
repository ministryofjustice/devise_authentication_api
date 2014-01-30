
require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  before :all do
    @email = 'joe.bloggs@example.com'

    @password = 's3kr!tpa55'
    @too_short_password = 'pass'

    @good_creds =         {user: {email: @email, password: @password} }
    @bad_password_creds = {user: {email: @email, password: 'wrong_password'} }
    @short_password_creds = {user: {email: @email, password: @too_short_password} }
    @bad_creds =          {user: {email: 'bad login'} }

    @new_password = 'new_pass'
    @new_password_params = {user: {password: @new_password}}
    @too_short_password_params = {user: {password: @too_short_password}}
  end

  def register_and_confirm credentials
    register credentials
    User.last.confirm!
  end

  def register credentials
    post('/users', credentials)
  end

  def sign_in credentials
    post('/sessions', credentials)
  end

  def user
    User.find_by(email: @email)
  end

  context 'unauthenticated user' do

    describe 'registers via POST /users' do
      describe 'success' do
        before { register_and_confirm @good_creds }

        it 'returns 201 Created status code' do
          status_code_is 201 # Created
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
          json_contains 'errors', {"email"=>["is invalid"], "password"=>["can't be blank"]}
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

    describe 'sign in via POST /sessions' do
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
          user.access_locked?.should be_false
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
          attempts = ENV['MAXIMUM_ATTEMPTS'].to_i
          attempts.times do |i|
            sign_in @bad_password_creds
          end
          sign_in @bad_password_creds
        end

        it "has locked user's access" do
          user.access_locked?.should be_true
        end

        context 'sign in attempt with good password' do
          before { sign_in @good_creds }

          it 'returns 401 Unauthorized status code' do
            status_code_is 401
          end

          it 'has account is locked error JSON' do
            json_contains 'error', 'Your account is locked.'
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

  context 'authenticated user' do
    before do
      user = User.create! @good_creds[:user]
      @token = user.authentication_token
    end

    describe 'GET /users/:token' do
      describe 'success' do
        before do
          get "/users/#{@token}"
        end

        it 'returns 200' do
          status_code_is 200
        end

        it 'returns X-USER-ID header' do
          last_response.headers['X-USER-ID'].should == @email
        end

        it 'returns blank body' do
          last_response.body.should == ''
        end
      end

      describe 'failure' do
        before do
          get "/users/bad_token"
        end

        it 'returns 401 Unauthorized status code' do
          status_code_is 401 # Unauthorized
        end

        it 'does not return X-USER-ID header' do
          last_response.headers['X-USER-ID'].should be_nil
        end

        it 'returns blank body' do
          last_response.body.should == ''
        end
      end
    end

    shared_examples 'unauthorized with invalid token error' do
      it 'returns 401 Unauthorized status code' do
        status_code_is 401 # Unauthorized
      end

      it 'returns "Invalid token." error' do
        json_contains 'error', 'Invalid token.'
      end
    end

    shared_examples 'no content success response' do
      it 'returns 204 No Content status code' do
        status_code_is 204
      end

      it 'returns blank body' do
        last_response.body.should == ''
      end
    end

    describe 'change password via PATCH /users/:token' do
      describe 'success' do
        before do
          patch "/users/#{@token}", @new_password_params
        end

        it_behaves_like 'no content success response'

        it 'changes user password' do
          User.last.valid_password?(@new_password)
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

    describe 'sign out via DELETE /sessions/[token]' do
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

end