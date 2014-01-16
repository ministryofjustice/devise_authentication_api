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
    last_response.status.should eq code
  end

end

RSpec.configure do |config|
  config.include ApiHelper, type: :api #apply to all spec for apis folder
end
