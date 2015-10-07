class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
  has_many :subscriptions
  has_many :users, through: :subscriptions
end
