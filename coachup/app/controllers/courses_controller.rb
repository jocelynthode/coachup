class CoursesController < ApplicationController
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

    @course.coach = current_user

    if @course.save
      redirect_to courses_path
    else
      render 'new'
    end

  end

  def update
    @course = Couse.find(params[:id])

    if @course.update(course_params)
      redirect_to @article
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
    @courses = get_my_courses
  end

  def courses_by_my_coaches_index
    #todo: change when partnerships are added
    @courses = Course.all
  end

  def courses_i_am_subscribed_to_index
    #todo: change when subscriptions are added
    @courses = Course.all
  end

  private
    def get_my_courses
      @my_courses = Array.new

      Course.find_each do |course|
        if course.coach_id == current_user.id
          @my_courses.push course
        end
      end

      return @my_courses
    end

    def course_params
      params.require(:course).permit(:title, :description, :price, :coach_id)
    end
end
