class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :training_sessions

  validates :title, presence: true
  validates :description, presence: true
  validates :coach_id, presence: true

  def self.url
    'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'
  end
  # TODO rework th rescue part
  def self.get_all_sports
    begin
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'sports/',
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)
        sports = []
        answer[:sports].each do |sport|
          sports << sport[:name]
        end
        sports
      else
        nil
      end
    rescue
      nil
    end
  end

  def self.get_courses_by_my_coaches
    begin
      @my_courses = []
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'partnerships/',
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)

        answer[:partnerships].each do |partnership|
          if partnership.user1 == current_user.username
            Course.find_each do |course|
              if course.coach.username == partnership.user2
                @my_courses. << course
              end
            end
          elsif partnership.user2 == current_user.username
            Course.find_each do |course|
              if course.coach_id == partnership.user1
                @my_courses << course
              end
            end
          end
        end

        return @my_courses
      else
        nil
      end
    rescue
      nil
    end
  end

  def self.get_my_subscribed_courses
    @my_courses = Array.new

    Subscription.find_each do |sub|
      if sub.user_id == current_user.id
        @my_courses.push Course.find(sub.course_id)
      end
    end

    return @my_courses
  end

  def self.get_my_courses
    @my_courses = Array.new

    Course.find_each do |course|
      if course.coach_id == current_user.id
        @my_courses << course
      end
    end
    return @my_courses
  end

  def self.apply(course, flash, current_user)
    if course.coach.id == current_user.id
      flash[:alert] = "You are the owner of this course!"
      return
    end

    @subscribtions = course.subscriptions
    if @subscribtions.present?
      @subscribtions.each do |sub|
        if sub.user == current_user
          flash[:alert] = "You are already subscribed!"
          return
        end
      end
    end

    if course.max_participants <= @subscribtions.count
      flash[:alert] = "Sorry! Maximum number of participants is already reached!"
      return
    end

    course.subscriptions << Subscription.create(:course => course, :user => current_user)
    flash[:notice] = "You are now subscribed to the course!"
    return
  end

  def self.leave(course, flash, current_user)
    if course.coach == current_user
      flash[:alert] = "You are the coach - you can't leave ;)"
      return
    end

    if !course.subscriptions.any? { |user| current_user}
      flash[:alert] = "You are not subscribed to the course!"
      return
    end

    @current_subscription = Subscription.find_by(:course => course, :user => current_user)
    if @current_subscription.present?
      @current_subscription.destroy
      flash[:notice] = "You are successfully unsubscribed from the course!"
      return
    end
  end
end
