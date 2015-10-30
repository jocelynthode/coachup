class MakeLocationIdNotNull < ActiveRecord::Migration
  def change
    change_column_null :courses, :location_id, false
  end
end
