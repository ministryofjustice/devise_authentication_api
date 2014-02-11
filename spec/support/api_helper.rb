module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def json_includes key
    JSON.parse(last_response.body)[key].should_not be_blank
  end

  def json_contains key, value
    JSON.parse(last_response.body)[key].should == value
  end

  def json_should_not_contain key
    JSON.parse(last_response.body).should_not have_key(key)
  end

  def status_code_is code
    last_response.status.should == code
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

  def user email
    User.find_by(email: email)
  end

end

RSpec.configure do |config|
  config.include ApiHelper, type: :api #apply to all spec for apis folder
end
