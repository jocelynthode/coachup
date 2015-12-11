module UsersHelper
  def full_name(username)
    user = User.find_by(username: username)
    return nil if user.nil?

    begin
      coach_user = CoachClient::User.new(coach_client, username, password: user.password)
      coach_user.update
      coach_user.realname
    rescue CoachClient::Exception
      nil
    end
  end
end
