require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  before :all do
    @email = 'joe.bloggs@example.com'
    @good_creds = {user: {email: @email, password: 's3kr!tpa55'} }
    @bad_creds = {user: {email: 'bad login'} }
  end

  def register credentials
    post('/users.json', credentials)
  end

  def sign_in credentials
    post('/users/sign_in.json', credentials)
  end

  context 'Unauthenticated user' do

    describe 'register via POST /users.json' do
      describe 'success' do
        before { register @good_creds }

        it 'returns 201 status code' do
          status_code_is 201
        end

        it 'returns email in JSON' do
          json_contains 'email', @email
        end
      end

      describe 'failure' do
        before { register @bad_creds }

        it 'returns 422 status code' do
          status_code_is 422
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
          status_code_is 201
        end

        it 'returns a secure token' do
          token = User.last.authentication_token
          token.should_not be_nil
          json_contains 'authentication_token', token
        end
      end

      describe 'failure' do
        before { sign_in @bad_creds }

        it 'returns 401 status code' do
          status_code_is 401
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

    describe 'GET /users/token.json' do
      describe 'sucess' do
        before do
          get "/users/#{@token}.json"
        end

        it 'returns 200' do
          status_code_is 200
        end

        it 'returns email in JSON' do
          json_contains 'email', @email
        end
      end

      describe 'failure' do
        before do
          get "/users/bad_token.json"
        end

        it 'returns 401 status code' do
          status_code_is 401
        end

        it 'returns email in JSON' do
          json_should_not_contain 'email'
        end
      end
    end

    describe 'sign out via DELETE /users/sign_out' do
      it 'returns 204 status code' do
        sign_in @good_creds
        delete "/sessions/#{@token}.json"
        User.last.authentication_token.should_not eq @token
        status_code_is 204
      end

      it 'returns blank body' do
        sign_in @good_creds
        delete "/sessions/#{@token}.json"
        last_response.body == ''
      end
    end

  end

end