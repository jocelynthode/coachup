class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :description
      t.integer :price
      t.references :coach, index: true
      t.timestamps null: false
    end
    add_foreign_key :courses, :users, column: :coach_id
  end
end
