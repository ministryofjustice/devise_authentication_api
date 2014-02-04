require 'spec_helper'

describe 'seed initial admin user' do

  context 'after app initialization' do
    before do
      INITIALIZE_ADMIN_USER.call # see config.after_initialize in application.rb
    end

    it 'has created admin user' do
      User.where(email: ENV['INITIAL_ADMIN_USER_EMAIL']).exists?.should be_true
    end

    it 'has set is_admin_user to true' do
      User.find_by(email: ENV['INITIAL_ADMIN_USER_EMAIL']).is_admin_user.should be_true
    end
  end

end