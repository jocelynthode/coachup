class CoursesController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]
  before_action :require_authorization, only: [:edit, :update, :destroy]
  before_action :permit_edit, only: [:edit, :update]

  def index
    if params[:user_id]  # /users/:id/courses
      @user = User.find(params[:user_id])
      @courses = @user.taught_courses
    elsif params[:q] == nil
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
    @course[:starts_at] = 1.day.from_now
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

    if @course.update(course_params)
      begin
        user = CoachClient::User.new(coach_client, session[:username],
                                     password: session[:password])
        subscription = CoachClient::UserSubscription.new(coach_client, user,
                                                         course_params[:sport],
                                                         publicvisible: 2)
        subscription.save
      rescue CoachClient::Exception
        flash[:alert] = "Could not save changes"
        redirect_to edit_course_path(@course)
      end
      CourseMailer.details_update(@course).deliver_now
      flash[:notice] = "Successfully updated course"
      redirect_to @course
    else
      if not @course.errors.any?
        # Only give this error if we don't have anything more specific to say
        flash[:alert] = "Could not save changes"
      end
      render 'edit'
    end
  end

  def destroy
    @course = Course.find(params[:id])
    subscriptions = @course.subscriptions
    if @course.destroy
      CourseMailer.course_deleted(@course, subscriptions).deliver_now
      flash[:notice] = "Successfully deleted course"
      redirect_to courses_path
    else
      flash[:alert] = "Could not delete course"
      redirect_to @course
    end
  end


  def apply
    @course = Course.find(params[:course_id])
    @msg, @channel = @course.apply(current_user)

    # TODO: Check if request went well before applying the user in the DB and sending a mail
    # Notify coach
    CourseMailer.user_application(@course, current_user).deliver_now

    user = CoachClient::User.new(coach_client, session[:username],
                                 password: session[:password])
    subscription = CoachClient::UserSubscription.new(coach_client, user,
                                                     @course.sport,
                                                     publicvisible: 2)
    begin
      subscription.save
    rescue CoachClient::Exception
      flash[:alert] = "Could not create subscriptions"
    end

    redirect_to course_path(@course)
  end

  def leave
    @course = Course.find(params[:course_id])
    @msg, @channel = @course.leave(current_user)
    @course.reload
    CourseMailer.user_application(@course, current_user, true).deliver_now
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
                                   location_attributes: [:id, :address, :latitude, :longitude])
  end


  def permit_edit
    course = Course.find(params[:id])
    if course.retrieve_schedule.next_occurrence.nil?
      flash[:alert] = "Can't edit a course that has already ended"
      redirect_to courses_path
      return false
    end
    true
  end

  def require_authorization
    course = Course.find(params[:id])
    redirect_to course_path unless course && current_user == course.coach
  end
end

