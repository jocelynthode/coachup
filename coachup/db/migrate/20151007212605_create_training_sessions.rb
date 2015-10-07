class CreateTrainingSessions < ActiveRecord::Migration
  def change
    create_table :training_sessions do |t|
      t.string :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.float :lat
      t.float :lng
      t.references :course, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
