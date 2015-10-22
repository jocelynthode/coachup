class GooglemapsController < ApplicationController
  def index
    @googlemaps = Googlemap.all
    @hash = Gmaps4rails.build_markers(@googlemaps) do |googlemap, marker|
      marker.lat googlemap.latitude
      marker.lng googlemap.longitude
    end
  end

  def show
    @googlemap = Googlemap.find(params[:id])
    @hash = Gmaps4rails.build_markers(@googlemap) do |googlemap, marker|
      marker.lat googlemap.latitude
      marker.lng googlemap.longitude
    end
  end

  def new
    @googlemap = Googlemap.new
  end

  def create
    @googlemap = Googlemap.new(google_params)

    if @googlemap.save
      redirect_to @googlemap
    else
      render 'new'
    end
  end

  private
  def google_params
    params.require(:googlemap).permit(:title, :latitude, :longitude, :description, :address)
  end
end
