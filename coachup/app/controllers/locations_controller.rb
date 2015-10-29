class LocationsController < ApplicationController
  def index
    @course = Course.find(params[:course_id])
    @locations = @course.locations
    @hash = Gmaps4rails.build_markers(@locations) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end
  def show
    @course = Course.find(params[:course_id])
    @location = @course.locations.find(params[:id])
    @hash = Gmaps4rails.build_markers(@location) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
      marker.title location.address
    end
  end

  def new
    @course = Course.find(params[:course_id])
    @location = @course.location.build
  end

  def create
    @course = Course.find(params[:course_id])
    @location = @course.location.create(location_params)
    redirect_to courses_path(@course, @location)
  end

  private
  def location_params
    params.require(:location).permit(:latitude, :longitude, :address)
  end
end
