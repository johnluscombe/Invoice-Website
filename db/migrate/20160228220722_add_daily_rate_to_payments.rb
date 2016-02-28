class AddDailyRateToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :daily_rate, :float
  end
end
