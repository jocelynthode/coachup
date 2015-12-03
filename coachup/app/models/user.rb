class User < ActiveRecord::Base
  acts_as_votable
  acts_as_voter
  # Virtual attribute for authenticating with either username or email
  attr_accessor :login, :realname, :publicvisible, :password_confirmation,
    :new_password, :new_password_confirmation, :avatar, :avatar_cache, :delete_avatar
  validates :realname, presence: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  # creating user
  validates :username, presence: true, length: {within: 3..50}, uniqueness: true
  validates :password, length: {within: 3..50}, on: :create
  validates_presence_of :password_confirmation, on: :create
  validates_confirmation_of :password, on: :create
  # editing user
  validates :new_password, length: {within: 3..50}, if: :new_password_present?, on: :update
  validates_presence_of :new_password_confirmation, if: :new_password_present?, on: :update
  validates_confirmation_of :new_password, if: :new_password_present?, on: :update
  validates :phone, format: { with: /\A(\d+[\s\d]*)*\z/ }, on: :update

  mount_uploader :avatar, AvatarUploader

  has_many :taught_courses, class_name: 'Course', foreign_key: 'coach_id'
  has_many :subscriptions
  has_many :courses, through: :subscriptions

  def self.url
    'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'
  end

  def self.authenticate(username, password)
    begin
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'authenticateduser/',
                                             user: username, password: password,
                                             headers: { accept: :json })
      if response.code == 200
        JSON.parse(response, symbolize_names: true)
      else
        false
      end
    rescue
      false
    end
  end

  def get_next_sessions
    date_course = Struct.new(:date, :course)
    all_dates = Set.new
    self.subscriptions.each do |sub|
      schedule = sub.course.retrieve_schedule
      occ = schedule.occurrences(sub.course.ends_at)
      occ.each do |date|
        element = date_course.new
        element.date = date
        element.course = sub.course
        if element.date.to_i >= Time.now.to_i
          all_dates.add(element)
        end
      end
    end

    if (all_dates.count == 0)
      false
    end

    all_dates = all_dates.sort_by { |date| date.date}
    all_dates.take(10)
  end

  def self.get_full_name(username)
    begin
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'users/'+username,
                                             headers: { accept: :json })
      if response.code == 200
        answer = JSON.parse(response, symbolize_names: true)
        answer[:realname]
      else
        false
      end
    rescue
      false
    end
  end

  def approval_rate
    return 100 if self.votes_for.size == 0
    (self.get_upvotes.size.to_f / self.votes_for.size) * 100
  end

  def subscribed_to_course_from?(user)
    subs = self.subscriptions
    return false if subs.nil?
    subs.each do |sub|
      return true if sub.course.coach == user
    end
    false
  end

  private
  def new_password_present?
    new_password.present?
  end
end
