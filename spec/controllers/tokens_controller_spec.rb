require 'spec_helper'

describe 'get X-USER-ID via GET /users/:authentication_token' do

  include ApiHelper
  include_context "shared setup"

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

  end
end