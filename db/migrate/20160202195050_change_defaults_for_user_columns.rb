class ChangeDefaultsForUserColumns < ActiveRecord::Migration
  def change
    change_column :users, :first_time, :boolean, default: true
    change_column :users, :master, :boolean, default: true
  end
end
