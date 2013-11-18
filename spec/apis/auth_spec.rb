require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  context 'Unauthenticated user' do

    before :all do
      @email = 'joe.bloggs@example.com'
      @good_creds = {user: {email: @email, password: 's3kr!tpa55'} }
      @bad_creds = {user: {email: 'bad login'} }
    end

    describe 'POST /users.json' do
      describe 'success' do
        before { post('/users.json', @good_creds) }

        it 'returns 201 status code' do
          status_code_is 201
        end

        it 'returns email in JSON' do
          json_contains 'email', @email
        end
      end

      describe 'failure' do
        before { post('/users.json', @bad_creds) }

        it 'returns 422 status code' do
          status_code_is 422
        end

        it 'returns errors in JSON' do
          json_contains 'errors', {"email"=>["is invalid"], "password"=>["can't be blank"]}
        end
      end
    end

    describe 'POST /users/sign_in' do
      before { post('/users.json', @good_creds) }

      describe 'success' do
        before { post('/users/sign_in.json', @good_creds) }

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
        before { post('/users/sign_in.json', @bad_creds) }

        it 'returns 401 status code' do
          status_code_is 401
        end

        it 'doesn\'t return a secure token' do
          json_should_not_contain 'token'
        end
      end
    end

  end
end