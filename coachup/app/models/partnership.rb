class Partnership
  # We assume here that we will only access partnerships owned by the user authenticated, since it
  # makes everything easier and we don't need anything else with our interpretation of partnerships.
  def initialize(coach_user)
    @coach_user = coach_user
  end

  def find
    @coach_user.update
    # slow, but required for user_confirmed
    @coach_user.partnerships.each(&:update).select(&:user1_confirmed)
  end

  def create(username)
    partnership = CoachClient::Partnership.new(@coach_user.client, @coach_user, username,
                                               publicvisible: 0)
    partnership.propose
  end

  def destroy(username)
    partnership = CoachClient::Partnership.new(@coach_user.client, @coach_user, username)
    partnership.cancel
  end
end
