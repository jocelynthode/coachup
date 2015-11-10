class Partnership

  # We assume here that we will only access partnerships owned by the user authenticated, since it
  # makes everything easier and we don't need anything else with our interpretation of partnerships.

  # TODO: keep the CyberCoach API baseurl in some global variable? or use User.url ?

  def baseurl(path_until=nil)
    url = 'http://%s:%s@diufvm31.unifr.ch:8090' % [@username, @password]
    url << '/CyberCoachServer/resources' if path_until == :resources
    url
  end

  def initialize(username, password)
    @username = username
    @password = password
  end

  def find(coach_username=nil)
    raw_partnerships = []
    next_url = baseurl(:resources) + '/users/' + @username + '?size=50'
    while next_url
      response = RestClient.get(next_url, {accept: :json})
      data = JSON.parse(response, symbolize_names: true)
      raw_partnerships.concat data[:partnerships] if data[:partnerships]

      # Pagination
      next_url = nil
      if data[:links] then
        data[:links].each do |link|
          next_url = baseurl + link[:href] if link[:description] == 'next'
        end
      end
    end
    return [] if raw_partnerships.empty?

    partnerships = Array.new
    raw_partnerships.each do |ps|
      # extract partner's username
      m = ps[:uri].match(Regexp.new '/partnerships/([^/;]+);([^/;]+)/')
      user = m.to_a.drop(1).select { |x| x != @username }.first
      next if coach_username and user != coach_username

      # Only add partnerships confirmed by our user.
      # We need to get the full data of each partnership for that
      response = RestClient::Request.execute(method: :get,
                                             url: baseurl + ps[:uri],
                                             headers: {accept: :json})
      fulldata = JSON.parse(response, symbolize_names: true)
      if (fulldata[:user1][:username] == @username and fulldata[:userconfirmed1]) or
          (fulldata[:user2][:username] == @username and fulldata[:userconfirmed2]) then

        partnerships << ps.merge(:user => user,
                                 :created_at => Time.at(fulldata[:datecreated]/1000.0),
                                 :publicvisible => fulldata[:publicvisible])
      end
    end

    return partnerships
  end

  def create(username)
    response = RestClient::Request.execute(method: :put,
                                           url: partnership_url(username),
                                           payload: {publicvisible: 0})
    response.code
  end

  def delete(username)
    response = RestClient.delete partnership_url(username)
    response.code
  end


  protected

    def partnership_url(username)
      baseurl(:resources) + '/partnerships/' + [@username, username].map{|x| CGI.escape x}.join(';')
    end

end