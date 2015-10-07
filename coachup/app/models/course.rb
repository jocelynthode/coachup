class Course < ActiveRecord::Base
  belongs_to :coach, class_name: "User"
end
