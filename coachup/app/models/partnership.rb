class Partnership

  # We assume here that we will only access partnerships owned by the user authenticated, since it
  # makes everything easier and we don't need anything else with our interpretation of partnerships.
  def initialize(username, password)
    @username = username
    @password = password
  end

  def find(coach_client)
    user = CoachClient::User.new(coach_client, @username, password: @password)
    user.update
    # slow, but required for user_confirmed
    user.partnerships.each(&:update)
  end

  def create(coach_client, username)
    user = CoachClient::User.new(coach_client, @username, password: @password)
    partnership = CoachClient::Partnership.new(coach_client, user, username,
                                               publicvisible: 0)
    partnership.propose
  end

  def destroy(coach_client, username)
    user = CoachClient::User.new(coach_client, @username, password: @password)
    partnership = CoachClient::Partnership.new(coach_client, user, username)
    partnership.delete
  end
end

