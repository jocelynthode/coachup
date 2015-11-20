class AddDurationToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :duration, :time, null: false
  end
end
