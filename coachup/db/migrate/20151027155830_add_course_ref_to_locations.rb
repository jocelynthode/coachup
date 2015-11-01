class AddCourseRefToLocations < ActiveRecord::Migration
  def change
    add_reference :locations, :course, index: true, foreign_key: true
  end
end
