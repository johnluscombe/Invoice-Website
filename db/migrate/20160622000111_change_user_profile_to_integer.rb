class ChangeUserProfileToInteger < ActiveRecord::Migration
  def change
    change_column :users, :profile, :integer, default: 1
  end
end
