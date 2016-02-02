class FixDefaultMasterForUsers < ActiveRecord::Migration
  def change
    change_column :users, :master, :boolean, default: false
  end
end
