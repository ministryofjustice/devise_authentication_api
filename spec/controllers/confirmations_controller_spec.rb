require 'spec_helper'

describe 'confirmation via POST /users/confirmation/:confirmation_token' do

  include ApiHelper
  include_context 'shared setup'

  context 'by unconfirmed user' do
    describe 'success' do
      before do
        register @good_creds
        confirmation_token = JSON.parse(last_response.body)['confirmation_token']
        post "/users/confirmation/#{confirmation_token}"
      end

      it_behaves_like 'no content success response'

      it 'has confirmed user' do
        user(@email).confirmed?.should be_true
      end
    end
  end

  context 'by suspended user' do
    before do
      register @good_creds
      @confirmation_token = JSON.parse(last_response.body)['confirmation_token']
      @user = user(@email)
      @user.suspended = true
      @user.save
    end

    describe 'failure' do
      before do
        post "/users/confirmation/#{@confirmation_token}"
      end

      it_behaves_like 'account suspended response'

      it 'has not confirmed user' do
        user(@email).confirmed?.should be_false
      end
    end

    context 'that is reinstated' do
      before do
        @user.suspended = false
        @user.save
        post "/users/confirmation/#{@confirmation_token}"
      end

      it_behaves_like 'no content success response'

      it 'has confirmed user' do
        user(@email).confirmed?.should be_true
      end
    end
  end

  context 'by already confirmed user' do
    describe 'failure' do
      before do
        register @good_creds
        confirmation_token = JSON.parse(last_response.body)['confirmation_token']
        post "/users/confirmation/#{confirmation_token}"
        post "/users/confirmation/#{confirmation_token}"
      end

      it 'returns 401 Unauthorized status code' do
        status_code_is 401
      end

      it 'returns "Invalid token." error' do
        json_contains 'error', 'Invalid token.'
      end
    end
  end

  context 'with bad confirmation_token' do
    describe 'failure' do
      before do
        post "/users/confirmation/bad_token"
      end

      it 'returns 401 Unauthorized status code' do
        status_code_is 401
      end

      it 'returns "Invalid token." error' do
        json_contains 'error', 'Invalid token.'
      end
    end
  end

end