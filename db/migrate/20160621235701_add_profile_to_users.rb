class AddProfileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile, :integer
    remove_column :users, :admin, :boolean
    remove_column :users, :master, :boolean
  end
end
