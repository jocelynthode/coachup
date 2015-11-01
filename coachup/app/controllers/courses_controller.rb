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
    @courses = Course.get_courses_by_my_coaches
  end

  def courses_i_am_subscribed_to_index
    @courses = Course.get_my_subscribed_courses
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
