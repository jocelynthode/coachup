class MyPartnershipsController < ApplicationController

  def index

    start = params[:start] || 0
    size = params[:size] || 10

    response = rest_request(:get, MyPartnershipsHelper.url + 'partnerships/', accept: :json,
                                          params:{start: start, size:size})

    @partnerships = response['partnerships'].map {|partnership| partnership['id']}


=begin
    user= Partnership.new("user123","test123")
=end


  end

  def show







    response = rest_request(:get, MyPartnershipsHelper.url + 'partnerships/' + params[:id],
                            accept: :json)
    if bad_request?(response)
      redirect_to action: :index
      return
    end

    @partnership = response.reject {}

    @id = @partnership['id']
    @user1 = @partnership['user1']['username']
    @user2 = @partnership['user2']['username']
    @user1conf = @partnership['userconfirmed1']
    @user2conf = @partnership['userconfirmed2']
  end

  def new

  end

  def edit

  end

  def create

  end

  def update

  end

  def destroy

  end

  private

  def rest_request(method, url, **args)
    begin
      response = RestClient::Request.execute(method: method, url: url, headers: args)

      JSON(response)
    rescue RestClient::Exception => exception
      exception
    end
  end

  def bad_request?(response)
    if response.is_a?(RestClient::Exception)
      true
    else
      false
    end
  end



end
