class AddTimestampsToUsers < ActiveRecord::Migration
  def change
    add_timestamps :users, null: false
  end
end
