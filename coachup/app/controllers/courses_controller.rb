class CoursesController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    if params[:q] == nil then
      @courses = Course.all
    else
      @courses = Course.search(params[:q]).result
      #Do we want to check for users too ? if so we'll have to move the search result to a different page
      #@users = User.search(username_or_name_or_last_name_cont: params[:q]).result
    end
  end

  def show
    @course = Course.find(params[:id])

    @hash = Gmaps4rails.build_markers(@course.location) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
      marker.title location.address
    end
  end

  def new
    @course = Course.new
    @location = @course.build_location
  end

  def edit
    @course = Course.find(params[:id])
  end

  def create
    @course = Course.new(course_params)
    @course.coach_id = current_user.id

    if @course.save
      redirect_to courses_path
    else
      render 'new'
    end

  end

  def update
    @course = Course.find(params[:id])

    response = authenticated_put("users/#{current_user.username}/#{course_params[:sport]}",
                                 {publicvisible: 2})

    if @course.update(course_params) && !bad_request?(response)
      CourseMailer.details_update(@course).deliver_now
      flash[:notice] = "Successfully updated Course"
      redirect_to @course
    else
      flash[:alert] = "Could not save changes"
      redirect_to edit_course_path
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    redirect_to courses_path
  end

  def my_courses_index
    @courses = Course.where(:coach_id => current_user.id);
  end

  def courses_by_my_coaches_index
    partnerships = current_user_partnerships.find()
    @partnerships = partnerships.map { |ps|
      user = User.find_by(username: ps[:user])
      if @user.present?
        ps.merge :user_id => user.id
      end
    }.compact

    my_courses = []

    @partnerships.each do |partnership|
      Course.find_each do |course|
        if course.coach_id == partnership[:user_id]
          my_courses << course
        end
      end
    end
    @courses = my_courses
  end

  def courses_i_am_subscribed_to_index
    @courses = Course.joins(:subscriptions).where(subscriptions: { user_id: current_user.id})
  end

  def apply
    @course = Course.find(params[:course_id])
    @msg, @channel = @course.apply(current_user)

    # TODO: Check if request went well before applying the user in the DB and sending a mail
    # Notify coach
    CourseMailer.user_application(@course, current_user).deliver_now

    url = Course.url + 'users/' + current_user.username + '/' + @course.sport
    payload = { publicvisible: "2" }
    payload_xml = payload.to_xml(root: :subscription, skip_instruct: true)
    begin
      response = rest_put(url, payload_xml, accept: :json, content_type: :xml)
    end

    if bad_request?(response)
      @channel = :alert
      @msg = "Something went wrong"
    end

    flash[@channel] = @msg
    redirect_to course_path(@course)
  end

  def leave
    @course = Course.find(params[:course_id])
    @msg, @channel = @course.leave(current_user)
    @course.reload
    CourseMailer.user_application(@course, current_user, has_left=true).deliver_now
    flash[@channel] = @msg
    redirect_to course_path(@course)
  end

  def export
    if session[:token]
      token = session.delete(:token)
      course = Course.find(params[:course_id])
      course.export_schedule(token)
      redirect_to course_path(course), notice: "Successfully exported to calendar"
    else
      session[:return_to] ||= request.original_url
      redirect_to '/auth/google_oauth2'
    end
  end

  private
  def course_params
    params.require(:course).permit(:title, :description, :price, :coach_id, :sport, :max_participants, :schedule,
                                   :starts_at, :ends_at, :duration,
                                   location_attributes: [:address, :latitude, :longitude])
  end

  def rest_put(url, payload, **args)
    begin
      response = RestClient::Request.execute(method: :put, url: url,
                                             payload: payload,
                                             user: session[:username],
                                             password: session[:password],
                                             headers: args)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
  end

  def rest_request(method, url, **args)
    begin
      response = RestClient::Request.execute(method: method, url: url,
                                             headers: args)
      JSON.parse(response, symbolize_names: true)
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

  def exception_code(exception)
    exception.response.code
  end
end
