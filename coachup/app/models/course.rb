class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  delegate :username, :to => :coach
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :training_sessions
  has_many :locations

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
          #todo: use current_user
          if partnership.user1 == "user123"
            Course.find_each do |course|
              if course.coach.username == partnership.user2
                @my_courses. << course
              end
            end
            #todo: use current_user
          elsif partnership.user2 == "user123"
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
      #todo currentuser-thingie
      if course.coach_id == 3
        @my_courses << course
      end
    end
    return @my_courses
  end

  def self.apply(course, flash)
    if course.coach.id = 3
      flash[:alert] = "You are the owner of this course!"
      return
    end

    @subscribtions = course.subscriptions
    if @subscribtions.present?
      @subscribtions.each do |sub|
        #todo: currentuser
        if sub.user == User.find(3)
          flash[:alert] = "You are already subscribed!"
          return
        end
      end
    end

    if course.max_participants <= @subscribtions.count
      flash[:alert] = "Sorry! Maximum number of participants is already reached!"
      return
    end

    #todo: currentuser
    course.subscriptions << Subscription.create(:course => course, :user => User.find(3))
    flash[:notice] = "You are now subscribed to the course!"
    return
  end
end
