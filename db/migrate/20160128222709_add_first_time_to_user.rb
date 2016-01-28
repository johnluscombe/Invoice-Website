class AddFirstTimeToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_time, :boolean
  end
end
