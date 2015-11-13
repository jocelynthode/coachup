class MakeEndsAtNotNull < ActiveRecord::Migration
  def change
    change_column_null :courses, :ends_at, false
  end
end
