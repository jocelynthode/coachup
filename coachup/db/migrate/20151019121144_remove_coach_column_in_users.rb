class RemoveCoachColumnInUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :coach
  end
end
