class RenameGoogleMapsTable < ActiveRecord::Migration
  def change
    rename_table :googlemaps, :locations
  end
end
