class MergeTrainingSessionsIntoCourses < ActiveRecord::Migration
  def change
    add_column :courses, :schedule, :string
    add_column :courses, :starts_at, :datetime, null: false
    add_column :courses, :ends_at, :datetime
  end
end
