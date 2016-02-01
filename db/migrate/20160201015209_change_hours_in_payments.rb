class ChangeHoursInPayments < ActiveRecord::Migration
  def change
    change_column :payments, :hours, :float
  end
end
