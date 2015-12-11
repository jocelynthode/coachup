class MakePriceNotNull < ActiveRecord::Migration
  def change
    change_column :courses, :price, :integer, null: false, default: 0
  end
end
