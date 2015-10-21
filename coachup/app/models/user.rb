class User < ActiveRecord::Base
  # Virtual attribute for authenticating with either username or email
  attr_accessor :login, :username, :email, :realname, :publicvisible
  validates :real_name, presence: true
  validates :username, presence: true, length: {within: 3..50}, uniqueness: true
  validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i}
  validates :password, length: {within: 3..50}
  validates_presence_of :password_confirmation
  validates_confirmation_of :password

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
