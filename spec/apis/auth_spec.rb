require 'spec_helper'
require 'json'

describe 'auth api', :type => :api do

  def json_contains key, value
    JSON.parse(last_response.body)[key].should == value
  end

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
          last_response.status.should eq 201
        end

        it 'returns email in JSON' do
          json_contains 'email', @email
        end
      end

      describe 'failure' do
        before { post('/users.json', @bad_creds) }

        it 'returns 400 status code' do
          last_response.status.should eq 422
        end

        it 'returns errors in JSON' do
          json_contains 'errors', {"email"=>["is invalid"], "password"=>["can't be blank"]}
        end
      end
    end
  end
end