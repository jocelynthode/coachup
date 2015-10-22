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

    @course.coach = current_user

    if @course.save
      redirect_to courses_path
    else
      render 'new'
    end

  end

  def update
    @course = Course.find(params[:id])

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
    @courses = get_courses_by_my_coaches
  end

  def courses_i_am_subscribed_to_index
    @courses = get_my_subscribed_courses
  end

  private
    def get_courses_by_my_coaches

      return Course.all

=begin
      response = rest_request(:get, Course.url + 'partnerships/', accept: :json)

      @partnerships = response['partnerships'].map { |p| { user1: p.respond_to?("User1"), user2: p.respond_to?("User2") } }

      # puts response

      for partnership in @partnerships
        if partnership.user1 == current_user.id
          Course.find_each do |course|
            if course.coach_id == partnership.user2
              @my_courses.push course
            end
          end
        elsif partnership.user2 == current_user.id
          Course.find_each do |course|
            if course.coach_id == partnership.user1
              @my_courses.push course
            end
          end
        end
      end
=end

    end

    def get_my_subscribed_courses
      @my_courses = Array.new

      Subscription.find_each do |sub|
        if sub.user_id == current_user.id
          @my_courses.push Course.find(sub.course_id)
        end
      end

      return @my_courses
    end

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

    def rest_request(method, url, **args)
      begin
        response = RestClient::Request.execute(method: method, url: url,
                                             headers: args)
        JSON.parse(response)
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
