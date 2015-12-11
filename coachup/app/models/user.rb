class User < ActiveRecord::Base
  acts_as_votable
  acts_as_voter

  has_many :taught_courses, class_name: 'Course', foreign_key: 'coach_id'
  has_many :subscriptions
  has_many :courses, through: :subscriptions

  attr_accessor :realname, :publicvisible, :password_confirmation,
                :new_password, :new_password_confirmation, :avatar,
                :avatar_cache, :delete_avatar

  validates :realname, presence: true
  validates :email, email: true
  # creating user
  validates :username, presence: true, length: { within: 3..50 }, uniqueness: true
  validates :password, length: { within: 3..50 }, confirmation: true, on: :create
  # editing user
  validates :new_password, length: { within: 3..50 }, confirmation: true, if: :new_password_present?, on: :update
  validates :phone, phone: true, on: :update

  mount_uploader :avatar, AvatarUploader

  def get_next_sessions
    date_course = Struct.new(:date, :course)
    all_dates = Set.new
    subscriptions.each do |sub|
      schedule = sub.course.retrieve_schedule
      occ = schedule.occurrences(sub.course.ends_at)
      occ.each do |date|
        element = date_course.new
        element.date = date
        element.course = sub.course
        all_dates.add(element) if element.date.start_time >= Time.current
      end
    end

    all_dates = all_dates.sort_by(&:date.date)
    all_dates.take(10)
  end

  def approval_rate
    return 100 if votes_for.size == 0
    (get_upvotes.size.to_f / votes_for.size) * 100
  end

  def subscribed_to_course_from?(user)
    subs = subscriptions
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
