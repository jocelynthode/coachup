class Location < ActiveRecord::Base
  has_one :course
  geocoded_by :address
  after_validation :geocode

  validates :address, presence: true, unless: 'address.blank?'
end
