class AddProfileFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :last_name, :string
    add_column :users, :address, :string
    add_column :users, :country, :string
    add_column :users, :phone, :string
    add_column :users, :date_of_birth, :string
    add_column :users, :trophies, :string
    add_column :users, :personal_records, :string
    add_column :users, :education, :string
    add_column :users, :coach, :boolean

  end
end
