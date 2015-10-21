class User < ActiveRecord::Base
  # Virtual attribute for authenticating with either username or email
  attr_accessor :login, :username, :email, :realname, :publicvisible
  validates_presence_of :username

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [ :login ]
  has_many :taught_courses, class_name: "Course"
  has_many :subscriptions
  has_many :courses, through: :subscriptions

  def self.url
    'http://diufvm31.unifr.ch:8090/CyberCoachServer/resources/'
  end

  def self.authenticate(username, password)
    begin
      response = RestClient::Request.execute(method: :get,
                                             url: self.url+'authenticateduser/',
                                             headers: { accept: :json })
      if response.code == 200
        session[:username] = username
        session[:password] = password
        JSON.parse(response, symbolize_names: true)
      else
        false
      end
    rescue RestClient::Exception => exception
      exception
    end
  end

  def self.current_user
    session[:username]
  end
end
