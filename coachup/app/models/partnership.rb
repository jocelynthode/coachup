class Partnership

  # We assume here that we will only access partnerships owned by the user authenticated, since it
  # makes everything easier and we don't need anything else with our interpretation of partnerships.

  # TODO: keep the CyberCoach API baseurl in some global variable? or use User.url ?
  @@url_format = 'http://%s:%s@diufvm31.unifr.ch:8090/CyberCoachServer/resources/'

  def baseurl
    self.url_format % [username, password]
  end

  def initialize(username, password)
    @username = username
    @password = password
  end

  def find(coach_username=nil)
    response = RestClient::Request.execute(method: :get,
                                           url: baseurl + '/users/' + username,
                                           headers: { accept: :json })
    data = JSON.parse(response, symbolize_names: true)
    return nil if not data[:partnerships]

    # if not coach_username
    #   return data[:partnerships]
    # end

    partnerships = Array.new
    data[:partnerships].each do |ps|
      m = ps[:uri].match(Regexp.new '/partnerships/([^/;]+);([^/;]+)/')
      users = m.to_a.drop(1)
      next if coach_username and not users.include? coach_username
      partnerships << ps.merge(:users => users)
    end
    partnerships
  end

end