class CoursesController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
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
=begin
    TODO find the location and update it using the params
    I think you'll have to create a locations_params
=end
    @course = Course.find(params[:id])

    if @course.update(course_params)
      redirect_to @course
    else
      render 'edit'
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
    begin
      my_courses = []
      response = RestClient::Request.execute(method: :get,
                                             url: Course.url+'partnerships/',
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)
        answer[:partnerships].each do |partnership|
          if partnership.include? current_user.username
            Course.find_each do |course|
              if partnership.include? course.coach.username
                unless course.coach_id == current_user.id
                  my_courses. << course
                end
              end
            end
          end
        end
      else
        nil
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
    flash[@channel] = @msg
    redirect_to course_path(@course)
  end

  def leave
    @course = Course.find(params[:course_id])
    @msg, @channel = @course.leave(current_user)
    flash[@channel] = @msg
    redirect_to course_path(@course)
  end

  private
    def course_params
      params.require(:course).permit(:title, :description, :price, :coach_id, :sport, :max_participants)
    end
end
