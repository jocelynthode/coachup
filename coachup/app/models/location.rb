class Location < ActiveRecord::Base
  belongs_to :course
  geocoded_by :address
  after_validation :geocode
end
