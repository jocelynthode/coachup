class RemoveColumnsFromLocations < ActiveRecord::Migration
  def self.up
    remove_column :locations, :title
    remove_column :locations, :description
  end
end
