require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  before :all do
    @email = 'joe.bloggs@example.com'
    @good_creds = {user: {email: @email, password: 's3kr!tpa55'} }
    @bad_creds = {user: {email: 'bad login'} }
  end

  def register credentials
    post('/users', credentials)
  end

  def sign_in credentials
    post('/users/sign_in', credentials)
  end

  context 'Unauthenticated user' do

    describe 'register via POST /users' do
      describe 'success' do
        before { register @good_creds }

        it 'returns 201 Created status code' do
          status_code_is 201 # Created
        end

        it 'returns email in JSON' do
          json_contains 'email', @email
        end

        it 'does not return _id in JSON' do
          json_should_not_contain '_id'
        end

        it 'returns authentication_token in JSON' do
          token = User.last.authentication_token
          json_contains 'authentication_token', token
        end
      end

      describe 'failure' do
        before { register @bad_creds }

        it 'returns 422 Unprocessable Entity status code' do
          status_code_is 422 # Unprocessable Entity
        end

        it 'returns errors in JSON' do
          json_contains 'errors', {"email"=>["is invalid"], "password"=>["can't be blank"]}
        end
      end
    end

    describe 'sign in via POST /users/sign_in' do
      before { register @good_creds }

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

      describe 'failure' do
        before { sign_in @bad_creds }

        it 'returns 401 Unauthorized status code' do
          status_code_is 401 # Unauthorized
        end

        it 'doesn\'t return a secure token' do
          json_should_not_contain 'token'
        end
      end
    end

  end

  context 'Authenticated user' do
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
          last_response.body == ''
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
          last_response.headers['X-USER-ID'].should == nil
        end

        it 'returns blank body' do
          last_response.body.should == ''
        end
      end
    end

    describe 'sign out via DELETE /users/sign_out' do
      before { sign_in @good_creds }

      describe 'success' do
        it 'returns 204 No Content status code' do
          delete "/sessions/#{@token}"
          User.last.authentication_token.should_not eq @token
          status_code_is 204 # No Content
        end

        it 'returns blank body' do
          delete "/sessions/#{@token}"
          last_response.body == ''
        end
      end

      describe 'failure' do
        it 'returns 401 Unauthorized status code' do
          delete "/sessions/bad_token"
          User.last.authentication_token.should eq @token
          status_code_is 401 # Unauthorized
        end

        it 'returns blank body' do
          delete "/sessions/bad_token"
          last_response.body == ''
        end
      end
    end

  end

end