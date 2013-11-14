require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  context 'Unauthenticated user' do

    before :all do
      @good_creds = {user: {email: 'joe.bloggs@example.com', password: 's3kr!tpa55'} }
      @bad_creds = {user: {email: 'bad login'} }
    end

    describe 'POST /users.json' do
      describe 'success' do
        it 'returns 201 status code' do
          post('/users.json', @good_creds)
          last_response.status.should eq 201
        end
      end

      describe 'failure' do
        it 'returns 400 status code' do
          post('/users.json', @bad_creds)
          last_response.status.should eq 422
        end
      end
    end
  end
end