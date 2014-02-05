class PasswordSetter

  def initialize user
    @user = user
  end

  def set_password password, responder
    @user.password = password
    if @user.valid?
      @user.save!
      responder.render_success
    else
      errors = @user.errors.messages.to_json
      responder.render_errors errors
    end
  end

end
