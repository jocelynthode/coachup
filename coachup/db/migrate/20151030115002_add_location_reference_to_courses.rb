class AddLocationReferenceToCourses < ActiveRecord::Migration
  def change
    add_reference :courses, :location, index: true, foreign_key: true
  end
end
