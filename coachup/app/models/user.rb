class User < ActiveRecord::Base
  # Virtual attribute for authenticating with either username or email
  attr_accessor :login
  validates_presence_of :username

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [ :login ]
  has_many :taught_courses, class_name: "Course"
  has_many :subscriptions
  has_many :courses, through: :subscriptions

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions.to_hash).first
      end
  end
end
