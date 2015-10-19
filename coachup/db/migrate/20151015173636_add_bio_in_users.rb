class AddBioInUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio, :string
    add_column :users, :aboutme, :string
  end
end
