module UsersHelper
  def full_name(username)
    begin
      user = coach_client.get_user(username)
      user.update
      user.realname
    rescue CoachClient::Exception
      ''
    end
  end
end

