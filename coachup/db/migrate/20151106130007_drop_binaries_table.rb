class DropBinariesTable < ActiveRecord::Migration
  def change
    drop_table :binaries
  end
end
