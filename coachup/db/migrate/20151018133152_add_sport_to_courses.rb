class AddSportToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :sport, :string
    add_column :courses, :max_participants, :integer, :default => 1
  end
end
