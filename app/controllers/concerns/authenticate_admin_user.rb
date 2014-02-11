module AuthenticateAdminUser

  extend ActiveSupport::Concern

  def return_unauthorised_if_not_admin_user_or_suspended
    token = params[:authentication_token]

    if (user = User.for_authentication_token(token)) && user.is_admin_user
      if user.suspended?
        render_unauthorized user.inactive_message
      else
        # ok
      end
    else
      render_unauthorized
    end
  end

end
