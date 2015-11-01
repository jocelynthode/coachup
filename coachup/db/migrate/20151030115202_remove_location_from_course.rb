class RemoveLocationFromCourse < ActiveRecord::Migration
  def change
    remove_column :courses, :address
    remove_column :courses, :longitude
    remove_column :courses, :latitude
  end
end
