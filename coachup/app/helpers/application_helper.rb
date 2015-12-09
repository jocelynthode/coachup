module ApplicationHelper
  def coach_client
    CoachClient::Client.new('http://diufvm31.unifr.ch:8090',
                            '/CyberCoachServer/resources/')
  end
end
