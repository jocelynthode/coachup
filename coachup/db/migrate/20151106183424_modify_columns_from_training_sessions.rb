class ModifyColumnsFromTrainingSessions < ActiveRecord::Migration
  def change
    remove_column :training_sessions, :lat
    remove_column :training_sessions, :lng
    add_column :training_sessions, :schedule, :string
  end
end
