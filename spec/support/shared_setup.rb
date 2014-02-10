shared_context "shared setup" do

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

shared_examples 'account suspended response' do
  it 'returns 401 status' do
    status_code_is 401
  end

  it 'returns error message' do
    json_contains 'error', 'Your account is suspended.'
  end
end
