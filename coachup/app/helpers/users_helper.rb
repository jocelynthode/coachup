module UsersHelper
  def full_name(username)
    begin
      user = coach_client.get_user(username)
      if user_signed_in? && current_user.username == username
        user.password = session[:password]
        user.update
      end
      user.realname
    rescue CoachClient::Exception
      ''
    end
  end
end

