class User < ActiveRecord::Base
  # Virtual attribute for authenticating with either username or email
  attr_accessor :login, :username, :email, :realname, :publicvisible, :password,
    :password_confirmation
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

  def self.request(method, path, **args)
    raise "Error: not signed in" unless user_signed_in?
    url = self.url + path
    header = { accept: :json }
    header.merge!(args)
    begin
      response = RestClient::Request.execute(method: method, url: url,
                                             user: session[:username],
                                             password: session[:password],
                                             headers: header)
      JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => exception
      exception
    end
  end
end
