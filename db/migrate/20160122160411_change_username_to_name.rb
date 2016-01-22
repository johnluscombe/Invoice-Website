class ChangeUsernameToName < ActiveRecord::Migration
  def change
    remove_column :users, :username, :string
    add_column :users, :name, :string
  end
end
