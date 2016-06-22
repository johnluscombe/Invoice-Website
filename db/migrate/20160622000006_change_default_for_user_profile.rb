class ChangeDefaultForUserProfile < ActiveRecord::Migration
  def change
    change_column :users, :profile, :boolean, default: 1
  end
end
