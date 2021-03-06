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

shared_examples 'sends confirmation email' do
  it 'sends confirmation email to new user' do
    ActionMailer::Base.deliveries.count.should == 1
    message = ActionMailer::Base.deliveries.first

    message.to.should == [@email]
    message.from.should == [ENV['SENDER_EMAIL_ADDRESS']]
    message.subject.should == 'Confirmation instructions'
    message.body.raw_source.should include('http://testhost/users/confirmation/')
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
  it 'returns 403 status' do
    status_code_is 403
  end

  it 'returns error message' do
    json_contains 'error', 'Your account is suspended.'
  end
end

shared_examples 'prevents invalid admin access' do
  describe 'failure due to suspended admin user' do
    before do
      @admin_user.suspended = true
      @admin_user.save

      call_api @admin_token, good_params
    end

    it_behaves_like 'account suspended response'
  end

  describe 'failure due to invalid user email' do
    before do
      call_api @admin_token, bad_email_params
    end

    it 'returns 422 status code' do
      status_code_is 422
    end

    it 'returns error message' do
      json_contains 'error', 'No user found for email.'
    end
  end

  describe 'failure due to invalid token' do
    before do
      call_api 'bad_token', good_params
    end

    it_behaves_like 'unauthorized with invalid token error'
  end
end
