module CoursesHelper
  def sports
    CoachClient::Sport.list(coach_client)
  end
end

