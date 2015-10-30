class Location < ActiveRecord::Base
  has_many :courses
  geocoded_by :address
  after_validation :geocode
end
