class AddRateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rate, :float
  end
end
