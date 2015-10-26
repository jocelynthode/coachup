class Partnership

  # We assume here that we will only access partnerships owned by the user authenticated, since it
  # makes everything easier and we don't need anything else with our interpretation of partnerships.

  # TODO: keep the CyberCoach API baseurl in some global variable? or use User.url ?
  @@url_format = 'http://%s:%s@diufvm31.unifr.ch:8090'

  def baseurl(path_until=nil)
    url = @@url_format % [@username, @password]
    url << '/CyberCoachServer/resources' if path_until == :resources
    url
  end

  def initialize(username, password)
    @username = username
    @password = password
  end

  def find(coach_username=nil)
    response = RestClient::Request.execute(method: :get,
                                           url: baseurl(:resources) + '/users/' + @username,
                                           headers: {accept: :json})
    data = JSON.parse(response, symbolize_names: true)
    return [] if not data[:partnerships]


    partnerships = Array.new
    data[:partnerships].each do |ps|
      # extract partner's username
      m = ps[:uri].match(Regexp.new '/partnerships/([^/;]+);([^/;]+)/')
      user = m.to_a.drop(1).select { |x| x != @username }.first
      next if coach_username and user != coach_username

      # only add partnerships confirmed by our user (may be costly)
      response = RestClient::Request.execute(method: :get,
                                             url: baseurl + ps[:uri],
                                             headers: {accept: :json})
      fulldata = JSON.parse(response, symbolize_names: true)
      if (fulldata[:user1][:username] == @username and fulldata[:userconfirmed1]) or
          (fulldata[:user2][:username] == @username and fulldata[:userconfirmed2]) then

        partnerships << ps.merge(:user => user,
                                 :created_at => fulldata[:datecreated],
                                 :publicvisible => fulldata[:publicvisible])
      end
    end

    return partnerships
  end

end