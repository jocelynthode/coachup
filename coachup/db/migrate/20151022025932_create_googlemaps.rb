class CreateGooglemaps < ActiveRecord::Migration
  def change
    create_table :googlemaps do |t|
      t.float :latitude
      t.float :longitude
      t.string :address
      t.string :description
      t.string :title

      t.timestamps null: false
    end
  end
end
